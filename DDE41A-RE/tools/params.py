"""Extract scalar calibration parameters and fault-path reports from a DDE41x O release.

Outputs (<variant>/out):
  labels.csv       the label pointer table at 0xF1000: every calibration label with type/size/value/users
  scalars.csv      calibration words read directly by code (not via the label pointer table)
  fault_paths.csv  every fault_report call: path index, error number, debounce config, error flag source

Fault reports: fault_report (0x092006 -> boot 0x2000) is called with
  R0.0 = error condition, R3 = (path << 4) | (error << 1), R1 = word at the debounce-config pointer,
  R2 = mask. Path numbering does not follow appendix A of the function description, so paths are
  reported by index only.
"""
import bisect
import csv
import json
import os
import struct
from collections import defaultdict

import variant as V
from c166 import decode

OUT = V.OUT
BASE = 0x80000


def main():
    img = open(V.IMAGE, "rb").read()
    an = json.load(open(os.path.join(OUT, "analysis.json")))
    maps = json.load(open(os.path.join(OUT, "maps.json")))
    names = {int(k, 16): v for k, v in an["functions"].items()}
    funcs = sorted(names)

    def w(a):
        return struct.unpack_from("<H", img, a - BASE)[0]

    def owner(a):
        k = bisect.bisect_right(funcs, a) - 1
        return funcs[k] if k >= 0 else None

    def cal(v):
        return (0xF0000 if v < 0x4000 else 0xF4000) + (v & 0x3FFF)

    in_map = {}
    for m in maps:
        in_map[m["addr"]] = m

    users = defaultdict(set)
    insns = defaultdict(list)
    for ia, ca, kind, how in an["calrefs"]:
        ia, ca = int(ia, 16), int(ca, 16)
        users[ca].add(owner(ia))
        insns[ca].append(ia)

    # label pointer table: consecutive DPP0/DPP1 pointers from 0xF1000 up to the first label
    ptab_lo, ptab_hi = V.label_table(img)
    targets = sorted({cal(w(a)) for a in range(ptab_lo, ptab_hi, 2)})
    data_end = V.data_end(img)  # erased flash (0xC3) follows the last label

    with open(os.path.join(OUT, "labels.csv"), "w", newline="") as f:
        wr = csv.writer(f)
        wr.writerow(["index", "pointer_at", "label_address", "bytes", "type", "dims", "value_or_first_words", "used_by"])
        nlab = defaultdict(int)
        for a in range(ptab_lo, ptab_hi, 2):
            t = cal(w(a))
            k = bisect.bisect_right(targets, t)
            nxt = targets[k] if k < len(targets) else data_end
            size = nxt - t
            m = in_map.get(t)
            if m:
                typ, dims = m["kind"], f"{m['nx']}x{m['ny']}" if m["kind"] == "KF" else str(m["nx"])
                val = f"x={m['xname']}" + (f" y={m['yname']}" if m["kind"] == "KF" else "")
            elif size == 2:
                v = w(t)
                typ, dims, val = "scalar", "1", f"0x{v:04X} ({v - 0x10000 if v & 0x8000 else v})"
            else:
                inner = [mm for aa, mm in in_map.items() if t < aa < nxt]
                typ = "struct+maps" if inner else "array"
                dims = str(size // 2)
                val = " ".join(f"{w(t + 2 * i):04X}" for i in range(min(8, size // 2)))
            nlab[typ] += 1
            u = users.get(a, set())
            wr.writerow([(a - ptab_lo) // 2, f"{a:06X}", f"{t:06X}", size, typ, dims, val,
                         " ".join(sorted(names.get(x, f"{x:06X}") for x in u if x))])

    with open(os.path.join(OUT, "scalars.csv"), "w", newline="") as f:
        wr = csv.writer(f)
        wr.writerow(["address", "value_hex", "value_u16", "value_s16", "n_refs", "used_by"])
        for ca in sorted(users):
            if ptab_lo <= ca < ptab_hi:
                continue
            v = w(ca)
            wr.writerow([f"{ca:06X}", f"0x{v:04X}", v, v - 0x10000 if v & 0x8000 else v, len(insns[ca]),
                         " ".join(sorted(names.get(u, f"{u:06X}") for u in users[ca] if u))])

    def back(site, n=10):
        for start in range(site - 34, site, 2):
            x, seq = start, []
            while x < site:
                i = decode(img, x - BASE, x)
                seq.append(i)
                x += i.size
            if x == site and not any(s.bad for s in seq):
                return seq[-n:]
        return []

    rows = []
    for s in an["calls"].get("092006", []):
        s = int(s, 16)
        r1 = r2 = r3 = flag = None
        for i in reversed(back(s)):
            op = i.ops
            if r3 is None and op.startswith("R3, #"):
                r3 = i.imm[0] if i.imm else int(op.split("#")[1], 0)
            elif r2 is None and op.startswith("R2, #"):
                r2 = i.imm[0] if i.imm else int(op.split("#")[1], 0)
            elif r1 is None and op.startswith("R1, ") and i.mem:
                r1 = i.mem[0][0]
            elif flag is None and i.mnem == "BMOV" and op.startswith("R0.0"):
                flag = op.split(", ")[1]
        cfg = cal(w(cal(r1))) if r1 is not None and r1 < 0x8000 and w(cal(r1)) < 0x8000 else None
        rows.append([f"{s:06X}", names.get(owner(s), ""),
                     r3 >> 4 if r3 is not None else "", (r3 >> 1) & 7 if r3 is not None else "",
                     f"0x{r3:04X}" if r3 is not None else "",
                     f"{cal(r1):06X}" if r1 is not None and r1 < 0x8000 else "",
                     f"{cfg:06X}" if cfg else "",
                     " ".join(f"{w(cfg + 2 * k):04X}" for k in range(3)) if cfg else "",
                     f"0x{r2:04X}" if r2 is not None else "", flag or ""])
    rows.sort(key=lambda r: (r[2] if r[2] != "" else 999, r[3] if r[3] != "" else 9))
    with open(os.path.join(OUT, "fault_paths.csv"), "w", newline="") as f:
        wr = csv.writer(f)
        wr.writerow(["call_site", "function", "path", "error", "r3", "cfg_pointer_word", "cfg_block",
                     "cfg_words", "r2_mask", "error_flag_bit"])
        wr.writerows(rows)

    nsc = sum(1 for ca in users if not (ptab_lo <= ca < ptab_hi))
    paths = {r[2] for r in rows if r[2] != ""}
    print(f"label table {ptab_lo:06X}..{ptab_hi - 2:06X}: {(ptab_hi - ptab_lo) // 2} labels {dict(nlab)}")
    print(f"direct (non-label) cal reads: {nsc}  fault reports: {len(rows)} on {len(paths)} paths")


if __name__ == "__main__":
    main()
