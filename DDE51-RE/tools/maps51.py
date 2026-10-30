"""Extract curves (KL) and maps (KF) from the DDE5.1 calibration.

Lookup routines (see README):
  fn_0583BC  curve: r3 = x, r4 = curve, r5 = index cache        layout n, x[n], y[n]          (int16)
  fn_0584B4  map:   r3 = x, r4 = y, r5 = map, r6 = index cache  layout nx, ny, x[nx], y[ny], z (int16)

Every call site of these routines with a resolved calibration address is decoded. The input variables
are traced back from the call site (last load into r3/r4 before the call). The value order of maps is
chosen by smoothness (x-fastest vs y-fastest). A structural scan of the whole calibration adds curves
and maps that no call site references directly (reached through pointers or unused in this variant).

Outputs: out/maps.json, out/maps.csv, out/maps.md
"""
import csv
import json
import os
import struct

import mem as M

KL_FN, KF_FN = "0583BC", "0584B4"


def s16(x):
    return x - 0x10000 if x & 0x8000 else x


def axis(m, a, n):
    v = [m.s16(a + 2 * k) for k in range(n)]
    return v if None not in v and all(v[k] < v[k + 1] for k in range(n - 1)) else None


def parse_kl(m, a):
    n = m.s16(a)
    if n is None or not 2 <= n <= 64:
        return None
    x = axis(m, a + 2, n)
    if not x:
        return None
    y = [m.s16(a + 2 + 2 * n + 2 * k) for k in range(n)]
    return dict(type="KL", addr=a, nx=n, ny=0, x=x, y=None, z=y, size=2 + 4 * n)


def roughness(z, nx, ny, xfast):
    g = (lambda i, j: z[j * nx + i]) if xfast else (lambda i, j: z[i * ny + j])
    r = 0
    for i in range(nx):
        for j in range(ny):
            if i + 1 < nx:
                r += abs(g(i + 1, j) - g(i, j))
            if j + 1 < ny:
                r += abs(g(i, j + 1) - g(i, j))
    return r


def parse_kf(m, a):
    nx, ny = m.s16(a), m.s16(a + 2)
    if nx is None or ny is None or not (2 <= nx <= 64 and 2 <= ny <= 64):
        return None
    x = axis(m, a + 4, nx)
    y = axis(m, a + 4 + 2 * nx, ny) if x else None
    if not (x and y):
        return None
    base = a + 4 + 2 * nx + 2 * ny
    z = [m.s16(base + 2 * k) for k in range(nx * ny)]
    if None in z:
        return None
    xfast = roughness(z, nx, ny, True) <= roughness(z, nx, ny, False)
    rows = [[(z[j * nx + i] if xfast else z[i * ny + j]) for i in range(nx)] for j in range(ny)]
    return dict(type="KF", addr=a, nx=nx, ny=ny, x=x, y=y, z=rows, order="x fastest" if xfast else "y fastest",
                size=4 + 2 * (nx + ny + nx * ny))


def input_var(m, insn_ea, func, call_at, reg, depth=0):
    """Walk back from the call to the last write of `reg`; return the variable it was loaded from."""
    a = call_at - 4
    while a >= func and call_at - a <= 160:
        w = m.u32(a)
        op, rt, ra = w >> 26, (w >> 21) & 31, (w >> 16) & 31
        if op in (32, 34, 40, 42) and rt == reg:                       # lwz/lbz/lhz/lha
            ea = insn_ea.get(a)
            return f"{ea}" if ea else f"[r{ra}{s16(w & 0xFFFF):+#x}]"
        if op == 31 and ((w >> 1) & 0x3FF) == 444 and ra == reg and rt == ((w >> 11) & 31) and depth < 3:
            return input_var(m, insn_ea, func, a, rt, depth + 1)       # mr reg, rS
        if op == 14 and rt == reg and depth < 3:
            if ra == 0:
                return f"const {s16(w & 0xFFFF)}"
            return input_var(m, insn_ea, func, a, ra, depth + 1) if s16(w & 0xFFFF) == 0 else f"r{ra}{s16(w & 0xFFFF):+d}"
        if (op in (14, 15, 7, 8, 12, 13, 21, 20) and (rt if op not in (20, 21) else ra) == reg) or \
           (op == 31 and (((w >> 1) & 0x3FF) in (28, 60, 124, 284, 316, 412, 444, 476, 24, 536, 792, 824, 26, 922, 954)
                          and ra == reg or rt == reg and ((w >> 1) & 0x3FF) not in (151, 183, 215, 247, 407, 439, 0, 32))):
            return "computed"
        a -= 4
    return "?"


def main():
    m = M.Mem()
    calls = json.load(open(os.path.join(M.OUT, "calls.json")))
    xrefs = json.load(open(os.path.join(M.OUT, "xrefs.json")))
    insn_ea = {}
    for k, v in xrefs.items():
        for x in v:
            if x[2] in ("r", "w"):
                insn_ea[x[0]] = k
    found = {}
    for c in calls:
        t = c["target"]
        reg = {KL_FN: "r4", KF_FN: "r5"}.get(t)
        if not reg or not c["args"].get(reg):
            continue
        a = int(c["args"][reg], 16)
        if not M.is_cal(a):
            continue
        obj = found.get(a) or (parse_kl(m, a) if t == KL_FN else parse_kf(m, a))
        if not obj:
            continue
        obj.setdefault("users", [])
        f, at = int(c["func"], 16), int(c["at"], 16)
        ins = {"x": input_var(m, insn_ea, f, at, 3)}
        if t == KF_FN:
            ins["y"] = input_var(m, insn_ea, f, at, 4)
        obj["users"].append(dict(func=c["func"], at=c["at"], **ins))
        found[a] = obj

    # structural scan for unreferenced curves/maps
    covered = set()
    for o in found.values():
        covered.update(range(o["addr"], o["addr"] + o["size"]))
    a = M.CAL[0] + 0x200
    while a < M.CAL[1] - 8:
        if a in covered:
            a += 2
            continue
        o = parse_kf(m, a) or parse_kl(m, a)
        if o and (o["type"] == "KF" or o["nx"] >= 4):
            o["users"] = []
            o["unreferenced"] = True
            found[a] = o
            covered.update(range(a, a + o["size"]))
            a += o["size"]
        else:
            a += 2

    objs = [found[k] for k in sorted(found)]
    for o in objs:
        o["addr_hex"] = f"{o['addr']:06X}"
    json.dump(objs, open(os.path.join(M.OUT, "maps.json"), "w"), indent=0)
    with open(os.path.join(M.OUT, "maps.csv"), "w", newline="") as fh:
        wr = csv.writer(fh)
        wr.writerow(["addr", "type", "nx", "ny", "x_min", "x_max", "y_min", "y_max", "z_min", "z_max", "functions", "inputs", "referenced"])
        for o in objs:
            zs = [v for row in o["z"] for v in row] if o["type"] == "KF" else o["z"]
            wr.writerow([o["addr_hex"], o["type"], o["nx"], o["ny"], o["x"][0], o["x"][-1],
                         o["y"][0] if o["y"] else "", o["y"][-1] if o["y"] else "", min(zs), max(zs),
                         " ".join(sorted({u["func"] for u in o["users"]})),
                         " | ".join(sorted({f"x={u['x']}" + (f" y={u['y']}" if 'y' in u else "") for u in o["users"]})),
                         "no" if o.get("unreferenced") else "yes"])
    with open(os.path.join(M.OUT, "maps.md"), "w", encoding="utf-8") as fh:
        nkl = sum(1 for o in objs if o["type"] == "KL")
        fh.write(f"# DDE5.1 7809330A / V7810913: curves and maps\n\nGenerated by `tools/maps51.py`. {nkl} curves, "
                 f"{len(objs) - nkl} maps; values are raw int16.\n\n")
        for o in objs:
            dims = f"{o['nx']}" if o["type"] == "KL" else f"{o['nx']}x{o['ny']}"
            fh.write(f"## {o['addr_hex']} {o['type']} {dims}" + (" (no direct reference)" if o.get("unreferenced") else "") + "\n\n")
            for u in o["users"][:6]:
                fh.write(f"- fn_{u['func']} @ {u['at']}: x = {u['x']}" + (f", y = {u['y']}" if "y" in u else "") + "\n")
            if o["type"] == "KF":
                fh.write(f"- value order: {o['order']}\n")
            fh.write("\n```text\n")
            fh.write("x : " + " ".join(str(v) for v in o["x"]) + "\n")
            if o["type"] == "KL":
                fh.write("y : " + " ".join(str(v) for v in o["z"]) + "\n")
            else:
                fh.write("rows = y, columns = x\n")
                for yv, row in zip(o["y"], o["z"]):
                    fh.write(f"{yv:>7} | " + " ".join(f"{v:6d}" for v in row) + "\n")
            fh.write("```\n\n")
    ref = sum(1 for o in objs if not o.get("unreferenced"))
    print(f"{len(objs)} objects ({nkl} KL, {len(objs) - nkl} KF); {ref} referenced by lookup calls, {len(objs) - ref} from structural scan")


if __name__ == "__main__":
    main()
