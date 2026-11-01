"""Decode the GS19.11 transmission calibration (6HP26/32, program 7556246A) and compare engine variants.

Data files: Shared/SP-Daten/E65/data/GKE191 (built into egs/bin by this script). The M67D44 (745d)
data is A7524745 ("E65 M67D44 ECE", assembly 7524744, type code HM61).

Layout of a data file (0x060000-0x07FFFF, addresses as in the ECU):
  0x060080  reference string (3x), header with range 0x060080-0x07A2FF and the ID "DAE47546"
  0x07A300  reference table, 5315 x 32-bit addresses in code order, ends 0xFFFFFFFF. Entries below
            0x073B70 point to data objects (3891 unique); entries >= 0x07A300 point to 334 pointer arrays
            inside the table area itself (parameter sets, e.g. per shift type)
  objects   unique data addresses; size = distance to the next one
  curves    int16 n, x[n], y[n]
  maps      int16 nx, ny, x[nx], y[ny], z[nx*ny]

Classes (relative to the M67D44): generic = same in all variants, diesel = same as the M57D30 TU2
(A7524743) but different from the petrol engines, M67 = differs from the M57.

The program code (0x080000-0x0E5BDF) is encrypted, so objects can only be identified by structure.

Usage: python egs191.py   -> out/egs191_cal.md, egs/egs191_objects.json
"""
import json
import os
import struct
import sys
from collections import Counter

import mem as M

sys.path.insert(0, os.path.join(M.REPO, "DDE41A-RE", "tools"))
import hex2bin  # noqa: E402

DATA_DIR = os.path.join(M.SP, "data", "GKE191")
EGS_BIN = os.path.join(M.ROOT, "egs", "bin")
BASE, TABLE, DATA_END = 0x060000, 0x07A300, 0x073B70
REF, DIESEL = "A7524745", "A7524743"


def load(name):
    out = os.path.join(EGS_BIN, name + ".bin")
    if not os.path.exists(out):
        os.makedirs(EGS_BIN, exist_ok=True)
        mem, _ = hex2bin.parse_hex(os.path.join(DATA_DIR, name + ".0da"))
        lo = min(mem) & ~0xFFFF
        open(out, "wb").write(hex2bin.to_image([mem], lo, ((max(mem) - lo) | 0xFFFF) + 1, 0xFF))
    return open(out, "rb").read()


def variants():
    """All data files of program 7556246A with their engine text (K_V2)."""
    out = {}
    for f in sorted(os.listdir(DATA_DIR)):
        if not f.lower().endswith(".0da"):
            continue
        hdr = open(os.path.join(DATA_DIR, f), encoding="latin-1").read(4000)
        ref = next((l.split(":", 1)[1].strip() for l in hdr.splitlines() if "ZL_Referenz" in l), "")
        v2 = next((l.split(":", 1)[1].strip() for l in hdr.splitlines() if l.startswith(";;K_V2")), "")
        if ref.startswith("047G150P461Z"):
            out[f[:-4]] = v2
    return out


def table(d):
    t, a = [], TABLE
    while True:
        v = struct.unpack_from(">I", d, a - BASE)[0]
        if not BASE <= v < 0x080000:
            return t
        t.append(v)
        a += 4


def s16(d, a):
    return struct.unpack_from(">h", d, a - BASE)[0]


def increasing(v):
    return all(v[i] < v[i + 1] for i in range(len(v) - 1))


def decode(d, a, n):
    k = s16(d, a)
    if 2 <= k <= 40 and n == 2 + 4 * k:
        x = [s16(d, a + 2 + 2 * i) for i in range(k)]
        if increasing(x):
            return dict(type="KL", x=x)
    ny = s16(d, a + 2)
    if 2 <= k <= 40 and 2 <= ny <= 40 and n == 4 + 2 * (k + ny + k * ny):
        x = [s16(d, a + 4 + 2 * i) for i in range(k)]
        y = [s16(d, a + 4 + 2 * k + 2 * i) for i in range(ny)]
        if increasing(x) and increasing(y):
            return dict(type="KF", x=x, y=y)
    return None


def values(d, a, o):
    if o["type"] == "KL":
        n = len(o["x"])
        return [s16(d, a + 2 + 2 * n + 2 * i) for i in range(n)]
    nx, ny = len(o["x"]), len(o["y"])
    b = a + 4 + 2 * (nx + ny)
    return [s16(d, b + 2 * i) for i in range(nx * ny)]


def main():
    names = variants()
    data = {k: load(k) for k in names}
    ref = data[REF]
    refs = table(ref)
    for k, d in data.items():
        if table(d) != refs:
            raise SystemExit(f"{k}: object table differs")
    addrs = sorted(set(v for v in refs if v < DATA_END)) + [DATA_END]
    arrays = sorted(set(v for v in refs if v >= TABLE))
    petrol = [k for k, v in names.items() if not any(e in v for e in ("M67", "M57"))]
    objs = []
    for i in range(len(addrs) - 1):
        a, n = addrs[i], addrs[i + 1] - addrs[i]
        raw = {k: d[a - BASE:a - BASE + n] for k, d in data.items()}
        m = raw[REF]
        if all(v == m for v in raw.values()):
            cls = "generic"
        elif m == raw[DIESEL] and all(raw[p] != m for p in petrol):
            cls = "diesel"
        elif m == raw[DIESEL]:
            cls = "diesel+some"
        elif any(raw[p] == m for p in petrol):
            cls = "M67+some"
        else:
            cls = "M67"
        o = dict(addr=f"{a:06X}", size=n, cls=cls, refs=refs.count(a), raw=m.hex(),
                 n_equal=sum(1 for v in raw.values() if v == m) - 1)
        st = decode(ref, a, n)
        if st:
            o.update(st)
            o["z"] = {k: values(d, a, st) for k, d in data.items()}
        objs.append(o)
    json.dump(dict(variants=names, objects=objs), open(os.path.join(M.ROOT, "egs", "egs191_objects.json"), "w"))

    cls = Counter(o["cls"] for o in objs)
    kinds = Counter((o.get("type", "other"), o["cls"]) for o in objs)
    L = ["# GS19.11 transmission calibration (program 7556246A, M67D44 data A7524745)\n",
         f"Generated by `tools/egs191.py`. {len(refs)} references at 0x07A300 to {len(objs)} data objects and "
         f"{len(arrays)} pointer arrays (inside the table area); {len(names)} data files of program 7556246A compared.\n",
         "| Data | Variant |\n|---|---|"] + [f"| {k} | {v} |" for k, v in names.items()]
    L.append("\n| Class | Objects | KL | KF |\n|---|---|---|---|")
    for c in ("generic", "diesel", "diesel+some", "M67", "M67+some"):
        L.append(f"| {c} | {cls[c]} | {kinds[('KL', c)]} | {kinds[('KF', c)]} |")

    L.append("\n## Objects specific to the diesels\n\nSame value in the M67D44 and the M57D30 TU2, different from every petrol "
             "engine. Values as int16 (curves/maps: axes and values), bytes for odd sizes.\n\n"
             "| Address | Size | Diesel | Petrol (most common) |\n|---|---|---|---|")
    pet = [k for k in names if k not in (REF, DIESEL) and not any(e in names[k] for e in ("M67", "M57"))]

    def show(d, a, n):
        b = d[a - BASE:a - BASE + min(n, 24)]
        s = " ".join(str(struct.unpack(">h", b[i:i + 2])[0]) for i in range(0, len(b) - 1, 2)) if n % 2 == 0 else b.hex()
        return s + (" ..." if n > 24 else "")
    for o in objs:
        if o["cls"] != "diesel":
            continue
        a, n = int(o["addr"], 16), o["size"]
        p = Counter(show(data[k], a, n) for k in pet).most_common(1)[0][0]
        kind = f"{o['type']} x={o['x']}" + (f" y={o['y']}" if o.get("y") else "") if o.get("type") else ""
        L.append(f"| 0x{o['addr']} | {n} {kind} | {show(ref, a, n)} | {p} |")
    open(os.path.join(M.OUT, "egs191_cal.md"), "w", encoding="utf-8").write("\n".join(L) + "\n")
    print(dict(cls), dict(kinds))


if __name__ == "__main__":
    main()
