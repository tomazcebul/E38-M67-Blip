"""Recursive-descent analysis of a DDE41x (EDC15C, C167) O-release image.

Produces:
  out/listing.asm        full disassembly of discovered code with labels and xrefs
  out/functions.csv      function start, size, callers, callees, calibration refs
  out/calrefs.csv        every instruction that references the calibration area 0xF0000-0xFBFFF
  out/analysis.json      machine-readable result used by the other tools

Usage: python analyze.py [image.bin]   (default: image of the selected variant, see variant.py)
"""
import csv
import json
import os
import sys
from collections import defaultdict

import variant as V
from c166 import decode

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = V.OUT
BASE = 0x80000
CODE_LO, CODE_HI = 0x90000, 0xF0000          # program area in the update file
CAL_LO, CAL_HI = 0xF0000, 0xFC000            # data/calibration area
# Data page pointers after init (0x0900BC): DPP0=0x3C, DPP1=0x3D, DPP3=3. DPP2 is switched at run time.
DEFAULT_DPP = [0x3C, 0x3D, None, 0x03]

# Boot-block services (segment 0, not part of the update file), identified from their call sites
BOOT_NAMES = {
    0x0CB2: "boot_KL_interp",      # R12 -> curve descriptor, R13 = input; result R4
    0x0CDC: "boot_KF_interp",      # R12 -> map descriptor, R13/R14 = inputs; result R4
    0x2000: "boot_fault_report",   # via 0x092006: R0.0 error bit, R3 = fault path*2, R1 = cfg, R2 = mask
    0x0830: "boot_task_prologue",  # 12-byte stub at the start of scheduler-called tasks
    0x02D6: "boot_fatal_reset",    # MDL = error code, interrupts disabled before the jump
}
FW_NAMES = {
    0x090082: "init_from_boot",
    0x092006: "fault_report",
}
# init helpers are named from the calls made by init_from_boot (same layout in master and slave)
INIT_CALLS = {0x090090: "init_ports", 0x0900B8: "init_bus_config"}
VARIANT_NAMES = {"A": {0x09664E: "can_controller_init"}}


def load_ram_names():
    p = os.path.join(OUT, "measurement_table.csv")
    names = {}
    if os.path.exists(p):
        for r in csv.DictReader(open(p, encoding="utf-8")):
            if r["sgbd_name"]:
                names.setdefault(int(r["ram_address"], 16), r["sgbd_name"])
    return names


# Bosch variable prefix -> chapter of the EDC15C function description
PREFIX_CHAPTER = {
    "anm": "02 Signal preprocessing", "adm": "02 Signal preprocessing", "ano": "02 Signal preprocessing",
    "dzm": "02 Signal preprocessing", "dim": "02 Signal preprocessing", "fgm": "07 Auxiliary (vehicle speed)",
    "mrm": "03 Fuel quantity control", "mro": "03 Fuel quantity control", "zum": "04 High pressure control",
    "zuo": "04 High pressure control", "arm": "05 EGR", "aro": "05 EGR", "ldm": "06 Boost pressure control",
    "ldo": "06 Boost pressure control", "ehm": "07 Auxiliary functions (actuators)", "gso": "07 Auxiliary (glow)",
    "zhm": "07 Auxiliary (heater)", "fbm": "A Fault handling", "fbo": "A Fault handling",
    "cam": "09 CAN", "cao": "09 CAN", "com": "09 CAN", "edm": "08 Monitoring", "xcm": "03 Fuel quantity control",
}


def chapter_guess(written):
    votes = defaultdict(int)
    for v in sorted(written):
        c = PREFIX_CHAPTER.get(v[:3])
        if c:
            votes[c] += 1
    if not votes or len(written) > 6:
        return ""
    return max(sorted(votes), key=votes.get)  # sorted: deterministic choice on a tie


def load(path):
    return open(path, "rb").read()


class Analyzer:
    def __init__(self, img):
        self.img = img
        self.insns = {}                     # addr -> Insn
        self.func_starts = set()
        self.calls = defaultdict(set)       # callee -> {call sites}
        self.jumps_in = defaultdict(set)
        self.data_refs = []                 # (insn addr, phys addr, kind, how)
        self.boot_calls = defaultdict(set)  # seg0 target -> sites
        self.entry_names = {}

    def in_code(self, a):
        return CODE_LO <= a < CODE_HI or CAL_LO <= a < CAL_HI

    def dec(self, a):
        return decode(self.img, a - BASE, a)

    def valid_start(self, a):
        """Reject targets that land in erased flash or immediately decode as garbage."""
        if not self.in_code(a) or a & 1:
            return False
        o = a - BASE
        if self.img[o:o + 4] in (b"\xc3\xc3\xc3\xc3", b"\xff\xff\xff\xff"):
            return False
        return True

    def resolve(self, m, ext, dpp):
        if ext and ext[0] in ("p", "pr") and ext[1] is not None:
            return ext[1] * 0x4000 + (m & 0x3FFF), "EXTP"
        if ext and ext[0] in ("s", "sr") and ext[1] is not None:
            return (ext[1] << 16) | m, "EXTS"
        if ext and ext[0] in ("p", "pr", "s", "sr"):
            return None, "EXT-reg"
        page = dpp[m >> 14]
        if page is None:
            return None, f"DPP{m >> 14}?"
        return page * 0x4000 + (m & 0x3FFF), f"DPP{m >> 14}"

    def explore(self, entries):
        work = list(entries)
        seen_blocks = set()
        while work:
            start = work.pop()
            if start in seen_blocks or not self.valid_start(start):
                continue
            seen_blocks.add(start)
            a = start
            ext = None          # (kind, value, remaining)
            dpp = list(DEFAULT_DPP)
            regimm = {}
            while self.in_code(a):
                if a in self.insns and a != start:
                    break
                i = self.dec(a)
                if i.bad:
                    i.flow = "bad"
                    self.insns[a] = i
                    break
                self.insns[a] = i
                # data page tracking
                if i.mnem == "MOV" and i.regw is not None and i.regw <= 3:
                    dpp[i.regw] = i.imm[0] & 0x3FF
                if i.regw is not None and i.regw >= 0xF0:
                    regimm[i.regw & 0xF] = i.imm[0]
                cur_ext = ext
                for m, rwk, _ in i.mem:
                    phys, how = self.resolve(m, cur_ext, dpp)
                    if phys is not None:
                        self.data_refs.append((a, phys, rwk, how))
                if i.mnem in ("MOV",) and i.ops.startswith("R") and "[R" in i.ops and "+#" in i.ops:
                    # MOV Rn,[Rm+#data16] with EXTP: table base in calibration/flash
                    if cur_ext and cur_ext[0] in ("p", "pr") and cur_ext[1] is not None:
                        phys = cur_ext[1] * 0x4000 + (i.imm[0] & 0x3FFF)
                        self.data_refs.append((a, phys, "r", "EXTP-idx"))
                # extended-addressing prefix bookkeeping
                if i.ext and i.ext[0] in ("p", "pr", "s", "sr"):
                    v = i.ext[1]
                    if v is None and i.ops.startswith("R"):
                        r = int(i.ops.split(",")[0][1:])
                        v = regimm.get(r)
                        v = v & (0x3FF if i.ext[0] in ("p", "pr") else 0xFF) if v is not None else None
                    ext = (i.ext[0], v, i.ext[2] + 1)
                if ext:
                    ext = (ext[0], ext[1], ext[2] - 1) if ext[2] > 1 else None

                t = i.target
                if t is not None:
                    if t < 0x10000 and i.mnem in ("CALLS", "JMPS"):
                        self.boot_calls[t].add(a)
                    elif i.flow == "call":
                        self.calls[t].add(a)
                        self.func_starts.add(t)
                        work.append(t)
                    elif i.flow in ("jmp", "cjmp"):
                        self.jumps_in[t].add(a)
                        work.append(t)
                        if i.mnem == "JMPS" and (t & 0xFF0000) != (a & 0xFF0000):
                            self.func_starts.add(t)
                if i.flow in ("jmp", "ret", "ijmp", "stop", "bad"):
                    break
                a += i.size

    def owner_map(self):
        """Assign every instruction to the nearest preceding function start."""
        starts = sorted(self.func_starts)
        owner = {}
        import bisect
        for a in self.insns:
            k = bisect.bisect_right(starts, a) - 1
            owner[a] = starts[k] if k >= 0 else None
        return owner


def sweep_call_targets(img, an):
    """Linear sweep over the program area, collecting call targets and code that follows returns.

    The application is dispatched by the boot block (not part of the update file), so most
    functions are only reachable via calls found by sweeping. Candidate runs are accepted only if
    they decode as a sequence of >= 6 valid instructions without hitting erased flash.
    """
    targets = defaultdict(int)
    after_ret = set()
    o = CODE_LO - BASE
    end = CODE_HI - BASE
    while o < end:
        if img[o:o + 2] in (b"\xc3\xc3", b"\xff\xff"):
            o += 2
            continue
        a = BASE + o
        i = decode(img, o, a)
        if i.bad:
            o += 2
            continue
        if i.flow == "call" and i.target is not None and an.valid_start(i.target):
            targets[i.target] += 1
        if i.flow == "ret" or (i.mnem in ("JMPS",) and i.target is not None and i.target < 0x10000):
            after_ret.add(a + i.size)
        o += i.size

    def plausible(t, n=6):
        x = t
        for _ in range(n):
            if not an.valid_start(x) and x != t:
                return False
            i = an.dec(x)
            if i.bad:
                return False
            if i.flow in ("ret", "jmp", "ijmp"):
                return True
            x += i.size
        return True

    calls = {t for t, n in targets.items() if plausible(t)}
    rets = {t for t in after_ret if an.valid_start(t) and plausible(t, 10)}
    return calls, rets


def find_pointer_tables(img, an):
    """Find tables of 32-bit (offset16, segment16) code pointers - EDC15 task/dispatch tables."""
    cands = set()
    for o in range(0x10000, len(img) - 4, 2):
        off = img[o] | img[o + 1] << 8
        seg = img[o + 2] | img[o + 3] << 8
        if 0x09 <= seg <= 0x0E:
            t = seg << 16 | off
            if an.valid_start(t) and t in an.insns:
                cands.add((BASE + o, t))
    # keep runs of >= 3 consecutive pointers
    by = {a: t for a, t in cands}
    runs = []
    for a in sorted(by):
        if a - 4 in by:
            continue
        run = []
        x = a
        while x in by:
            run.append((x, by[x]))
            x += 4
        if len(run) >= 3:
            runs.append(run)
    return runs


def main():
    path = sys.argv[1] if len(sys.argv) > 1 else V.IMAGE
    img = load(path)
    os.makedirs(OUT, exist_ok=True)
    an = Analyzer(img)
    fw_names = dict(FW_NAMES)
    fw_names.update(VARIANT_NAMES.get(V.KEY, {}))
    for site, nm in INIT_CALLS.items():
        i = an.dec(site)
        if i.mnem == "CALLS" and i.target and i.target >= 0x90000:
            fw_names[i.target] = nm
    plo, phi = V.label_table(img)

    entries = {0x090082: "init_from_boot", 0x0900EA: "start_jump"}
    # 0x092000 and 0xF0000 jump/vector tables: JMPS stubs
    for tbl_lo, tbl_hi in ((0x092000, 0x092040), (0x0F0000, 0x0F0200)):
        a = tbl_lo
        while a < tbl_hi:
            i = an.dec(a)
            if i.mnem == "JMPS" and i.target >= 0x90000:
                entries.setdefault(i.target, f"vec_{a:06X}")
            a += 2
    an.entry_names.update(entries)
    an.func_starts |= set(entries)
    an.explore(entries)

    # sweep-based discovery (call targets are treated as functions, code after returns as fragments)
    calls, rets = sweep_call_targets(img, an)
    for t in calls:
        an.func_starts.add(t)
    an.explore(sorted(calls))
    frag = [t for t in rets if t not in an.insns]
    for t in frag:
        an.func_starts.add(t)
        an.entry_names.setdefault(t, f"fn_{t:06X}")
    an.explore(frag)

    # iterate: pointer tables reveal more functions
    for _ in range(4):
        before = len(an.insns)
        runs = find_pointer_tables(img, an)
        new = []
        for run in runs:
            for pa, t in run:
                if t not in an.func_starts:
                    an.func_starts.add(t)
                    an.entry_names.setdefault(t, f"ptr_{pa:06X}")
                    new.append(t)
        # also every pointer-shaped value in tables pointing at undiscovered but plausible code
        an.explore(new)
        if len(an.insns) == before:
            break

    owner = an.owner_map()
    # calibration references
    calrefs = [(a, p, k, h) for a, p, k, h in an.data_refs if CAL_LO <= p < CAL_HI]
    # call graph
    callees = defaultdict(set)
    for callee, sites in an.calls.items():
        for s in sites:
            callees[owner.get(s)].add(callee)
    fsize = defaultdict(int)
    for a, i in an.insns.items():
        fsize[owner[a]] += i.size
    fcal = defaultdict(set)
    for a, p, k, h in calrefs:
        fcal[owner.get(a)].add(p)

    names = {}
    for f in sorted(an.func_starts):
        names[f] = fw_names.get(f) or an.entry_names.get(f, f"sub_{f:06X}")
    for t in an.boot_calls:
        names[t] = BOOT_NAMES.get(t, f"boot_{t:04X}")
    ramn = load_ram_names()
    fw_reads, fw_writes = defaultdict(set), defaultdict(set)
    for a, p, k, h in an.data_refs:
        if p in ramn:
            (fw_writes if "w" in k else fw_reads)[owner.get(a)].add(ramn[p])

    # label pointer table annotations (optional: maps.json from a previous maps.py run)
    def w16(a):
        return img[a - BASE] | img[a - BASE + 1] << 8

    maps_by_addr = {}
    mp = os.path.join(OUT, "maps.json")
    if os.path.exists(mp):
        for m in json.load(open(mp)):
            maps_by_addr[m["addr"]] = m

    def label_note(p):
        if not (plo <= p < phi):
            return ""
        v = w16(p)
        if v >= 0x8000:
            return ""
        t = (0xF0000 if v < 0x4000 else 0xF4000) + (v & 0x3FFF)
        m = maps_by_addr.get(t)
        if m:
            dims = f"{m['nx']}x{m['ny']}" if m["kind"] == "KF" else str(m["nx"])
            ins = m.get("xname", "") + (f",{m.get('yname')}" if m["kind"] == "KF" else "")
            return f" label#{(p - plo) // 2} -> {t:06X} {m['kind']} {dims} ({ins})"
        return f" label#{(p - plo) // 2} -> {t:06X}"

    # listing
    refs_by_insn = defaultdict(list)
    for a, p, k, h in an.data_refs:
        refs_by_insn[a].append((p, k, h))
    with open(os.path.join(OUT, "listing.asm"), "w", encoding="utf-8") as f:
        f.write(f"; {V.NAME} ({V.V['role']}) O release ({V.V['prg']} / {V.V['dat']}) - C167 disassembly, "
                "generated by tools/analyze.py\n")
        f.write("; DPP0=0x3C (0xF0000) DPP1=0x3D (0xF4000) DPP3=0x03 (RAM/SFR); DPP2 tracked locally\n\n")
        prev_end = None
        for a in sorted(an.insns):
            i = an.insns[a]
            if prev_end is not None and a != prev_end:
                f.write("\n")
            if a in an.func_starts:
                callers = sorted(an.calls.get(a, ()))
                f.write(f"\n;{'=' * 70}\n; {names[a]}   callers: {len(callers)}"
                        + (" (" + ", ".join(f'{c:06X}' for c in callers[:8]) + (" ..." if len(callers) > 8 else "") + ")" if callers else "")
                        + f"\n;{'=' * 70}\n{names[a]}:\n")
            elif a in an.jumps_in:
                f.write(f"loc_{a:06X}:\n")
            txt = i.text()
            if i.target is not None:
                tn = names.get(i.target) or (f"loc_{i.target:06X}" if i.target in an.insns else None)
                if tn:
                    txt += f"    ; -> {tn}"
            for p, k, h in refs_by_insn.get(a, []):
                tag = "CAL" if CAL_LO <= p < CAL_HI else ("FLASH" if 0x80000 <= p < CAL_LO else "RAM")
                nm = f" {ramn[p]}" if p in ramn else label_note(p)
                txt += f"    ; {tag} {p:06X}{nm} [{h},{k}]"
            f.write(f"  {a:06X}: {i.raw.hex():<8}  {txt}\n")
            prev_end = a + i.size

    with open(os.path.join(OUT, "functions.csv"), "w", newline="") as f:
        w = csv.writer(f)
        w.writerow(["address", "name", "bytes", "n_callers", "n_callees", "n_cal_refs", "writes", "reads",
                    "chapter_guess", "callees", "cal_refs"])
        for fs in sorted(an.func_starts):
            w.writerow([f"{fs:06X}", names[fs], fsize.get(fs, 0), len(an.calls.get(fs, ())),
                        len(callees.get(fs, ())), len(fcal.get(fs, ())),
                        " ".join(sorted(fw_writes.get(fs, ()))), " ".join(sorted(fw_reads.get(fs, ()))),
                        chapter_guess(fw_writes.get(fs, ())),
                        " ".join(names.get(c, f"{c:06X}") for c in sorted(callees.get(fs, ()))),
                        " ".join(f"{c:06X}" for c in sorted(fcal.get(fs, ())))])

    with open(os.path.join(OUT, "calrefs.csv"), "w", newline="") as f:
        w = csv.writer(f)
        w.writerow(["insn", "function", "cal_address", "access", "via", "instruction"])
        for a, p, k, h in sorted(calrefs):
            w.writerow([f"{a:06X}", names.get(owner.get(a), ""), f"{p:06X}", k, h, an.insns[a].text()])

    json.dump({
        "functions": {f"{k:06X}": names[k] for k in sorted(an.func_starts)},
        "calls": {f"{k:06X}": sorted(f"{s:06X}" for s in v) for k, v in an.calls.items()},
        "boot_calls": {f"{k:06X}": sorted(f"{s:06X}" for s in v) for k, v in an.boot_calls.items()},
        "calrefs": [[f"{a:06X}", f"{p:06X}", k, h] for a, p, k, h in calrefs],
        "ramrefs": [[f"{a:06X}", f"{p:06X}", k, h] for a, p, k, h in an.data_refs if p < 0x80000],
        "code_bytes": sum(i.size for i in an.insns.values()),
    }, open(os.path.join(OUT, "analysis.json"), "w"), indent=0)

    print(f"instructions: {len(an.insns)}  code bytes: {sum(i.size for i in an.insns.values())}")
    print(f"functions: {len(an.func_starts)}  boot-block targets: {len(an.boot_calls)}")
    print(f"calibration refs: {len(calrefs)} unique cal addresses: {len(set(p for _, p, _, _ in calrefs))}")


if __name__ == "__main__":
    main()
