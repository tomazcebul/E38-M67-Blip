"""Find and decode calibration curves (KL) and maps (KF) in a DDE41x O-release data area.

Bosch EDC15C layout (verified against code: e.g. 0x9D3C8 writes the input to 0xDCBA, then
calls the curve interpolator boot_0CB2 with R12 -> descriptor 0xF237E whose first word is 0xDCBA):

  curve  KL : [x_input RAM addr][nx][x_1 .. x_nx][v_1 .. v_nx]
  map    KF : [x_input RAM addr][nx][x_1 .. x_nx][y_input RAM addr][ny][y_1 .. y_ny][v (nx*ny), y fastest]

The value order (y fastest, i.e. column-major v[x*ny + y]) was determined by smoothness: in all 44
maps with nx,ny >= 4 this order is smoother than x-fastest.

Curves/maps are embedded in parameter structures that are reached through a pointer table at
0xF1000 (16-bit DPP0/DPP1 pointers). Code reads those pointers with "MOV Rn, 0x1xxx"; this links
each structure (and the maps inside it) to the functions that use it.

Outputs (../out): maps.csv, maps.json, maps.md
"""
import bisect
import csv
import json
import os
import re
import struct
from collections import defaultdict

import variant as V

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = V.OUT
DOC = os.path.join(HERE, "..", "..", "EDC15C-Function-Description", "de")
BASE = 0x80000
CAL_LO, CAL_HI = 0xF0000, 0xFC000
MAXN = 40
COMMON = {"dzmNmit", "anmWTF"}  # inputs that appear in too many doc paragraphs to name a curve by


def load():
    img = open(V.IMAGE, "rb").read()
    meas = {}
    p = os.path.join(OUT, "measurement_table.csv")
    if os.path.exists(p):
        for r in csv.DictReader(open(p, encoding="utf-8")):
            a = int(r["ram_address"], 16)
            if r["sgbd_name"] and a not in meas:
                meas[a] = r
    return img, meas


def w(img, a):
    return struct.unpack_from("<H", img, a - BASE)[0]


def sw(v):
    return v - 0x10000 if v & 0x8000 else v


def monotonic(xs):
    if len(xs) < 2:
        return True
    if all(xs[k] < xs[k + 1] for k in range(len(xs) - 1)):
        return True
    s = [sw(x) for x in xs]
    return all(s[k] < s[k + 1] for k in range(len(s) - 1))


def is_ram(v):
    return 0xC000 <= v <= 0xFFFE and v != 0xFF1C and v != 0xC3C3


def try_axis(img, a):
    if a + 4 > CAL_HI:
        return None
    var, n = w(img, a), w(img, a + 2)
    if not is_ram(var) or not (2 <= n <= MAXN) or a + 4 + 2 * n > CAL_HI:
        return None
    xs = [w(img, a + 4 + 2 * k) for k in range(n)]
    if not monotonic(xs) or len(set(xs)) != n:
        return None
    if all(x == 0xC3C3 for x in xs):
        return None
    return var, n, xs


def scan(img):
    found = []
    a = CAL_LO
    while a < CAL_HI - 8:
        ax = try_axis(img, a)
        if not ax:
            a += 2
            continue
        xvar, nx, xs = ax
        b = a + 4 + 2 * nx
        ay = try_axis(img, b)
        if ay:
            yvar, ny, ys = ay
            d = b + 4 + 2 * ny
            size = d + 2 * nx * ny - a
            if d + 2 * nx * ny <= CAL_HI:
                vals = [w(img, d + 2 * k) for k in range(nx * ny)]
                found.append(dict(addr=a, kind="KF", xvar=xvar, nx=nx, x=xs, yvar=yvar, ny=ny, y=ys,
                                  data_addr=d, values=vals, size=size))
                a += size
                continue
        vals = [w(img, b + 2 * k) for k in range(nx)]
        found.append(dict(addr=a, kind="KL", xvar=xvar, nx=nx, x=xs, yvar=None, ny=1, y=[],
                          data_addr=b, values=vals, size=4 + 4 * nx))
        a += 4 + 4 * nx
    return found


def struct_owners(img):
    """Map calibration struct start -> set(functions) using code reads of pointer-table words."""
    an = json.load(open(os.path.join(OUT, "analysis.json")))
    funcs = sorted(int(k, 16) for k in an["functions"])
    names = {int(k, 16): v for k, v in an["functions"].items()}

    def owner(a):
        k = bisect.bisect_right(funcs, a) - 1
        return funcs[k] if k >= 0 else None

    direct = defaultdict(set)     # cal address read directly -> functions
    ptr = defaultdict(set)        # struct address (via pointer) -> functions
    plo, phi = V.label_table(img)
    for insn, cal, kind, how in an["calrefs"]:
        ia, ca = int(insn, 16), int(cal, 16)
        f = owner(ia)
        direct[ca].add(f)
        if plo <= ca < phi and how.startswith("DPP"):
            v = w(img, ca)
            if v < 0x8000:
                tgt = (0xF0000 if v < 0x4000 else 0xF4000) + (v & 0x3FFF)
                if CAL_LO <= tgt < CAL_HI:
                    ptr[tgt].add(f)
    return direct, ptr, names


def doc_candidates():
    """Collect calibration labels (xxw..., names containing KF/KL) with surrounding sentence."""
    labels = []
    if not os.path.isdir(DOC):
        return labels
    for fn in sorted(os.listdir(DOC)):
        if not fn.endswith(".md"):
            continue
        txt = open(os.path.join(DOC, fn), encoding="utf-8").read()
        for para in re.split(r"\n\s*\n", txt):
            labs = set(re.findall(r"\b([a-z]{2}w[A-Z][A-Za-z0-9_]*(?:KF|KL))\b", para))
            if not labs:
                continue
            vars_ = set(re.findall(r"\b([a-z]{2}[mo][A-Z][A-Za-z0-9_]*)\b", para))
            for l in labs:
                labels.append((l, fn, vars_))
    return labels


def main():
    img, meas = load()
    maps = scan(img)
    direct, ptr, fnames = struct_owners(img)
    struct_starts = sorted(ptr)

    def vname(a):
        r = meas.get(a)
        return r["sgbd_name"] if r else f"ram_{a:04X}"

    def scale(a):
        r = meas.get(a)
        if not r:
            return None
        try:
            return float(r["factor"]), float(r["offset"]), r["unit"]
        except ValueError:
            return None

    labels = doc_candidates()
    for m in maps:
        users = set()
        for a in range(m["addr"], m["addr"] + m["size"], 2):
            users |= direct.get(a, set())
        k = bisect.bisect_right(struct_starts, m["addr"]) - 1
        if k >= 0:
            s = struct_starts[k]
            nxt = struct_starts[k + 1] if k + 1 < len(struct_starts) else CAL_HI
            if m["addr"] < nxt:
                m["struct"] = s
                users |= ptr[s]
        m["users"] = sorted(u for u in users if u is not None)
        xs, ys = vname(m["xvar"]), (vname(m["yvar"]) if m["yvar"] else None)
        m["xname"], m["yname"] = xs, ys
        m["xscale"], m["yscale"] = scale(m["xvar"]), (scale(m["yvar"]) if m["yvar"] else None)
        cands = {}
        if not xs.startswith("ram_"):
            for lab, fn, vars_ in labels:
                if xs not in vars_:
                    continue
                score = 1
                if ys and not ys.startswith("ram_"):
                    if ys not in vars_:
                        continue
                    score += 2
                kind_tag = "KF" if m["kind"] == "KF" else "KL"
                other = "KL" if kind_tag == "KF" else "KF"
                if kind_tag in lab:
                    score += 2
                elif other in lab:
                    continue
                cands[lab] = max(cands.get(lab, 0), score)
        if cands:
            best = max(cands.values())
            # KF: both inputs must match; KL: only for inputs that are not ubiquitous
            ok = best >= 5 or (m["kind"] == "KL" and best >= 3 and xs not in COMMON)
            m["doc_candidates"] = sorted(l for l, s in cands.items() if s == best)[:4] if ok else []
        else:
            m["doc_candidates"] = []

    os.makedirs(OUT, exist_ok=True)
    with open(os.path.join(OUT, "maps.csv"), "w", newline="", encoding="utf-8") as f:
        wr = csv.writer(f)
        wr.writerow(["address", "type", "nx", "ny", "x_input", "y_input", "x_axis", "y_axis",
                     "data_address", "struct", "used_by", "doc_candidates"])
        for m in maps:
            wr.writerow([f"{m['addr']:06X}", m["kind"], m["nx"], m["ny"], m["xname"], m["yname"] or "",
                         " ".join(str(v) for v in m["x"]), " ".join(str(v) for v in m["y"]),
                         f"{m['data_addr']:06X}", f"{m['struct']:06X}" if m.get("struct") else "",
                         " ".join(fnames.get(u, f"{u:06X}") for u in m["users"]),
                         "; ".join(m["doc_candidates"])])
    json.dump([{**m, "users": [f"{u:06X}" for u in m["users"]]} for m in maps],
              open(os.path.join(OUT, "maps.json"), "w"), indent=0)

    def fmt_axis(vals, sc):
        if not sc:
            return " ".join(str(v) for v in vals), "raw"
        fa, fb, unit = sc
        return " ".join(f"{v * fa + fb:g}" for v in vals), unit

    with open(os.path.join(OUT, "maps.md"), "w", encoding="utf-8") as f:
        f.write(f"# {V.NAME} ({V.V['role']}) O release: calibration curves and maps\n\n")
        f.write("Generated by `tools/maps.py`. Axis and map values are raw 16-bit words. Where an axis input "
                "has an SGBD measurement entry, the SGBD factor/offset is shown as a *hint*: the SGBD scales the "
                "diagnostic telegram value, which for some signals is a byte rather than the RAM word "
                "(e.g. `zumP_RAIL`). Map values are stored y-fastest; rows below are y, columns x. "
                "`Doc candidates` are labels from the EDC15C function description whose paragraph mentions the "
                "same input signals: hints, not confirmed names.\n\n")
        kf = sum(1 for m in maps if m["kind"] == "KF")
        f.write(f"Found **{len(maps)}** structures: **{kf}** maps (KF), **{len(maps) - kf}** curves (KL).\n\n")
        for m in maps:
            title = f"## {m['addr']:06X} {m['kind']} {m['nx']}" + (f"x{m['ny']}" if m["kind"] == "KF" else "")
            f.write(title + "\n\n")
            f.write(f"- X input: `{m['xname']}` (RAM 0x{m['xvar']:04X})\n")
            if m["kind"] == "KF":
                f.write(f"- Y input: `{m['yname']}` (RAM 0x{m['yvar']:04X})\n")
            if m["users"]:
                f.write("- Used by: " + ", ".join(f"`{fnames.get(u, hex(u))}`" for u in m["users"]) + "\n")
            if m["doc_candidates"]:
                f.write("- Doc candidates: " + ", ".join(m["doc_candidates"]) + "\n")
            xa, xu = fmt_axis(m["x"], m["xscale"])
            f.write("\n```text\n")
            f.write(f"x raw      : {' '.join(str(v) for v in m['x'])}\n")
            if m["xscale"]:
                f.write(f"x SGBD-scaled [{xu}] (hint): {xa}\n")
            if m["kind"] == "KL":
                f.write(f"v [raw]: {' '.join(str(sw(v)) for v in m['values'])}\n")
            else:
                ya, yu = fmt_axis(m["y"], m["yscale"])
                if m["yscale"]:
                    f.write(f"y SGBD-scaled [{yu}] (hint): {ya}\n")
                f.write("rows = y raw, columns = x\n")
                ylab = [str(v) for v in m["y"]]
                for r in range(m["ny"]):
                    row = [m["values"][c * m["ny"] + r] for c in range(m["nx"])]
                    f.write(f"{ylab[r]:>9} | " + " ".join(f"{sw(v):6d}" for v in row) + "\n")
            f.write("```\n\n")
    kf = sum(1 for m in maps if m["kind"] == "KF")
    named = sum(1 for m in maps if not m["xname"].startswith("ram_"))
    used = sum(1 for m in maps if m["users"])
    print(f"maps: {len(maps)}  KF: {kf}  KL: {len(maps) - kf}  with named x-input: {named}  linked to code: {used}")


if __name__ == "__main__":
    main()
