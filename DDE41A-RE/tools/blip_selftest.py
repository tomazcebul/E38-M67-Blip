"""Self-test for the blip patch logic (Blip-Function.md, 5.5).

Runs the patch code of blip_patch.py instruction by instruction in a minimal C167 interpreter
(only the instructions the patch uses) against test frames: E65 TORQUE_GEARBX (0x0B5) layout,
BMW checksum and alive counter, signal validity, MIN(target, limit), status handling, the
extra protections and the switches.

The interpreter works on the instruction texts the assembler emitted (they are decoded back from
the binary with c166.py in blip_patch.py), so the bytes themselves aren't executed. It does not
replace a bench test: flags, MULU/DIVLU and ASHR follow the C167 manual, the task period and
the CAN hardware are not modelled.

Usage:  python blip_selftest.py        (exit code 1 if a check fails)
"""
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import blip_patch as bp  # noqa: E402

a = bp.build()
prog = sorted(a.expect)                       # (address, instruction text)
idx = {ad: i for i, (ad, _) in enumerate(prog)}
labels = a.labels


class Machine:
    def __init__(self):
        self.mem = {}
        self.r = [0] * 16
        self.Z = self.N = self.C = self.V = 0
        self.stack = []

    def rb(self, ad): return self.mem.get(ad, 0)
    def wb(self, ad, v): self.mem[ad] = v & 0xFF
    def rw(self, ad): return self.rb(ad) | (self.rb(ad + 1) << 8)
    def ww(self, ad, v): self.wb(ad, v); self.wb(ad + 1, v >> 8)

    def flags_nz(self, v, bits=16):
        v &= (1 << bits) - 1
        self.Z = int(v == 0)
        self.N = v >> (bits - 1)

    def sub(self, x, y, bits=16):
        m = (1 << bits) - 1
        res = (x - y) & m
        self.Z, self.N = int(res == 0), res >> (bits - 1)
        self.C = int((x & m) < (y & m))
        sx, sy, sr = (x >> (bits - 1)) & 1, (y >> (bits - 1)) & 1, res >> (bits - 1)
        self.V = int(sx != sy and sr != sx)
        return res

    def add(self, x, y, bits=16):
        m = (1 << bits) - 1
        res = (x + y) & m
        self.Z, self.N = int(res == 0), res >> (bits - 1)
        self.C = int(((x & m) + (y & m)) > m)
        sx, sy, sr = (x >> (bits - 1)) & 1, (y >> (bits - 1)) & 1, res >> (bits - 1)
        self.V = int(sx == sy and sr != sx)
        return res

    def cond(self, cc):
        Z, N, C, V = self.Z, self.N, self.C, self.V
        return {"UC": 1, "Z": Z, "NZ": 1 - Z, "N": N, "NN": 1 - N, "C": C, "ULT": C, "NC": 1 - C,
                "UGE": 1 - C, "SGT": int(not (Z or (N ^ V))), "SLE": int(Z or (N ^ V)), "SLT": N ^ V,
                "SGE": 1 - (N ^ V), "UGT": int(not (Z or C)), "ULE": int(Z or C)}[cc]


def run(m, entry, maxsteps=5000):
    pc = idx[entry]
    steps = 0
    while True:
        steps += 1
        assert steps < maxsteps, "endless loop"
        _, text = prog[pc]
        mn, _, rest = text.partition(" ")
        ops = [o.strip() for o in rest.split(",")] if rest else []
        nxt = pc + 1
        R = m.r

        def reg(o): return int(o[1:])
        def memad(o): return int(o, 16)
        def is_reg(o): return re.fullmatch(r"R\d+", o) is not None
        def is_rl(o): return re.fullmatch(r"RL\d+", o) is not None

        if mn == "RETS":
            return steps
        if mn == "PUSH": m.stack.append(R[reg(ops[0])])
        elif mn == "POP": R[reg(ops[0])] = m.stack.pop()
        elif mn == "CALLS": pass
        elif mn == "JMPA":
            if m.cond(ops[0][3:]): nxt = idx[labels[ops[1]]]
        elif mn == "MOV":
            d, s = ops
            if is_reg(d):
                if s.startswith("#"): v = int(s[1:], 16)
                elif is_reg(s): v = R[reg(s)]
                else: v = m.rw(memad(s))
                R[reg(d)] = v & 0xFFFF
            else:
                v = 0 if s == "ZEROS" else R[reg(s)]
                m.ww(memad(d), v)
            m.flags_nz(v)
        elif mn == "MOVB":
            d, s = ops
            if is_rl(d):
                if s.startswith("#"): v = int(s[1:], 16)
                elif s.startswith("["):
                    mm = re.fullmatch(r"\[R(\d+)\+#(0x[0-9A-Fa-f]+)\]", s)
                    v = m.rb((R[int(mm.group(1))] + int(mm.group(2), 16)) & 0xFFFF)
                else: v = m.rb(memad(s))
                n = reg(d[1:])
                R[n] = (R[n] & 0xFF00) | (v & 0xFF)
            else:
                v = 0 if s == "ZEROS" else R[reg(s[1:])] & 0xFF
                m.wb(memad(d), v)
            m.flags_nz(v, 8)
        elif mn == "MOVBZ":
            d, s = ops
            v = R[reg(s[1:])] & 0xFF if is_rl(s) else m.rb(memad(s))
            R[reg(d)] = v
            m.flags_nz(v, 8)
        elif mn in ("ADD", "SUB", "CMP", "AND", "OR"):
            d, s = ops
            x = R[reg(d)]
            if s.startswith("#"): y = int(s[1:], 16)
            elif is_reg(s): y = R[reg(s)]
            else: y = m.rw(memad(s))
            res = None
            if mn == "ADD": res = m.add(x, y)
            elif mn == "SUB": res = m.sub(x, y)
            elif mn == "CMP": m.sub(x, y)
            elif mn == "AND": res = x & y; m.flags_nz(res); m.C = m.V = 0
            else: res = x | y; m.flags_nz(res); m.C = m.V = 0
            if res is not None: R[reg(d)] = res & 0xFFFF
        elif mn == "CMPB":
            d, s = ops
            x = R[reg(d[1:])] & 0xFF
            m.sub(x, int(s[1:], 16) if s.startswith("#") else m.rb(memad(s)), 8)
        elif mn in ("ADDB", "ORB"):
            d, s = ops
            n, y = reg(d[1:]), int(s[1:], 16)
            x = R[n] & 0xFF
            res = m.add(x, y, 8) if mn == "ADDB" else (x | y)
            R[n] = (R[n] & 0xFF00) | (res & 0xFF)
        elif mn == "NEG":
            n = reg(ops[0]); R[n] = (-R[n]) & 0xFFFF; m.flags_nz(R[n])
        elif mn == "ASHR":
            n, k = reg(ops[0]), R[reg(ops[1])] & 0xF
            v = R[n]
            R[n] = ((v - 0x10000 if v & 0x8000 else v) >> k) & 0xFFFF
            m.flags_nz(R[n])
        elif mn == "MULU":
            p = R[reg(ops[0])] * R[reg(ops[1])]
            m.ww(bp.MDL, p & 0xFFFF); m.ww(bp.MDH, p >> 16)
        elif mn == "DIVLU":
            d = R[reg(ops[0])]
            num = (m.rw(bp.MDH) << 16) | m.rw(bp.MDL)
            m.ww(bp.MDL, (num // d) & 0xFFFF); m.ww(bp.MDH, num % d)
        else:
            raise Exception("unsupported instruction: " + text)
        pc = nxt


CAL, RXB5 = bp.C, bp.RXB5


def frame(tar_raw, adj_raw, st, alive, bad_chk=False, tail=(0x30, 0x00, 0x30)):
    """E65 TORQUE_GEARBX: chk 0-7, alive 8-11, TORQ_TAR 12-23, ADJR_POS 24-35, ST 36-37."""
    b = [0] * 8
    b[1] = (alive & 0xF) | ((tar_raw & 0xF) << 4)
    b[2] = (tar_raw >> 4) & 0xFF
    b[3] = adj_raw & 0xFF
    b[4] = ((adj_raw >> 8) & 0xF) | ((st & 3) << 4)
    b[5], b[6], b[7] = tail
    s = sum(b[1:]) + 0xB5
    b[0] = ((s & 0xFF) + (s >> 8)) & 0xFF
    if bad_chk:
        b[0] ^= 0x11
    return b


def setup(**over):
    m = Machine()
    cv = dict(bp.CAL_VALUES)
    cv.update(FUN=1, MDN=1000, XEGS=0, NMX=4000)
    cv.update(over)
    for k, v in cv.items():
        m.ww(CAL[k], v)
    m.ww(bp.INIT, bp.INIT_MAGIC)
    m.ww(bp.EGS1_PTR, 0xD700)                 # EGS1 copy: gear 3, no S_SCHALT, MD_IND_GS = 0xFF
    m.wb(0xD700, 0x03)
    m.wb(0xD703, 0xFF)
    m.ww(bp.DZMNMIT, 1500)
    m.ww(bp.ANMWTF, 3500)
    m.ww(bp.FGMFGAKT, 2000)
    m.ww(bp.BI_SOLL, 500)
    return m


def put(m, b, status=0):
    for i, x in enumerate(b):
        m.wb(RXB5 + i, x)
    m.wb(RXB5 + 8, status)


def step(m):
    m.r = [0] * 16
    m.ww(bp.QTY, 0)
    run(m, bp.H3_ENTRY)
    return m.rb(bp.STAT), m.rw(bp.Q), m.rw(bp.QTY)


def q_of(nm, mdn=1000, bi=500, mmx=3000):
    md = min(nm * 255 // mdn, 254)
    return min(md * bi // 500, mmx)


results = []


def check(name, cond, info=""):
    results.append(bool(cond))
    print(("PASS " if cond else "FAIL ") + name, info)


def feed(m, n, tar, adj, st, al=0, **kw):
    out = None
    for _ in range(n):
        put(m, frame(tar, adj, st, al, **kw))
        al = (al + 1) % 15
        out = step(m)
    return out, al


# request, limit and status
m = setup(); (st, q, qty), _ = feed(m, 4, 200, 1200, 1)
check("valid request passes through", st == 1 and q == q_of(100) and qty == q, f"stat={st} q={q}")
m = setup(); (st, q, qty), _ = feed(m, 3, 800, 300, 1)
check("MIN(target, limit)", st == 1 and q == q_of(150), f"stat={st} q={q}")
for stv in (0, 2, 3):
    m = setup(); (st, q, qty), _ = feed(m, 3, 200, 1200, stv)
    check(f"ST={stv}: no request", q == 0 and st == 0, f"stat={st} q={q}")
for name, tar, adj in (("TORQ_TAR invalid 800H", 0x800, 1200), ("ADJR_POS invalid 800H", 200, 0x800),
                       ("ADJR_POS default 1000 Nm", 200, 2000), ("TORQ_TAR negative", 0xFF0, 1200)):
    m = setup(); (st, q, qty), _ = feed(m, 3, tar, adj, 1)
    check(name + ": no request", q == 0, f"stat={st} q={q}")

# BMW checksum and alive counter
m = setup(); _, al = feed(m, 3, 200, 1200, 1)
sts = []
for _ in range(4):
    put(m, frame(200, 1200, 1, al, bad_chk=True)); al = (al + 1) % 15
    sts.append(step(m))
check("bad checksum: status 64, no blip", all(s[0] & 0x40 and s[2] == 0 for s in sts), str(sts))
for _ in range(30):
    put(m, frame(200, 1200, 1, al, bad_chk=True)); al = (al + 1) % 15
    last = step(m)
check("repeated bad checksum: locked (status 8)", last[0] & 8 and last[2] == 0, str(last))
m = setup(CHK=0)
b = frame(200, 1200, 1, 0); b[0] = 0; b[1] &= 0xF0
for _ in range(3):
    put(m, b); st, q, qty = step(m)
check("CHK=0 accepts a frame without checksum and alive counter", st == 1 and q == q_of(100), f"stat={st} q={q}")
m = setup(ALVN=5); sts = []
for _ in range(12):
    put(m, frame(200, 1200, 1, 3)); sts.append(step(m)[0])
check("stuck alive counter: status 64", any(s & 0x40 for s in sts), str(sts))
m = setup(); put(m, frame(200, 1200, 1, 0xF)); st, q, qty = step(m)
check("alive counter 0xF: fault", st & 0x40 and q == 0, f"stat={st} q={q}")

# DDE-side conditions and extra protections
m = setup(NMX=1400); (st, q, qty), _ = feed(m, 3, 200, 1200, 1)
check("E3: rpm >= NMX cuts the blip (status 128)", st == 0x80 and q == 0, f"stat={st} q={q}")
m = setup(); m.wb(0xD703, 0x80); (st, q, qty), _ = feed(m, 3, 200, 1200, 1)
check("EGS1 reducing: no blip (status 16)", q == 0 and st & 0x10, f"stat={st} q={q}")
m = setup(XEGS=1); (st, q, qty), _ = feed(m, 3, 200, 1200, 1)
check("E2 on, no shift: no blip", q == 0, f"stat={st} q={q}")
m = setup(XEGS=1); _, al = feed(m, 3, 0, 0, 0)
m.wb(0xD700, 0x08 | 0x02)                      # S_SCHALT, target gear 2: downshift
(st, q, qty), _ = feed(m, 3, 200, 1200, 1, al)
check("E2 on, downshift inside the window: blip", st == 1 and q == q_of(100), f"stat={st} q={q}")
m = setup(XEGS=1); _, al = feed(m, 3, 0, 0, 0)
m.wb(0xD700, 0x08 | 0x04)                      # S_SCHALT, target gear 4: upshift
(st, q, qty), _ = feed(m, 3, 200, 1200, 1, al)
check("E2 on, upshift: no blip", q == 0, f"stat={st} q={q}")
m = setup(TMX=5); sts = []
al = 0
for _ in range(10):
    put(m, frame(200, 1200, 1, al)); al = (al + 1) % 15; sts.append(step(m))
check("maximum duration: status 4, blip withdrawn", any(s[0] & 4 for s in sts) and sts[-1][1] == 0, str(sts[-3:]))
m = setup(); put(m, frame(200, 1200, 1, 0)); step(m)
put(m, frame(200, 1200, 1, 1), status=4); st, q, qty = step(m)
check("receive timeout: status 32", st & 0x20, f"stat={st}")
m = setup(); _, al = feed(m, 3, 200, 1200, 1)
put(m, frame(200, 1200, 0, al)); st, q, qty = step(m)
check("ST 1 -> 0 ends the blip abruptly", q == 0 and qty == 0, f"stat={st} q={q}")
m = setup(FUN=0); put(m, frame(200, 1200, 1, 0)); st, q, qty = step(m)
check("FUN=0 is inert", q == 0 and qty == 0)

# a frame captured on a real E65 (idle, ST=0, TORQ_TAR and ADJR_POS invalid)
m = setup(); put(m, list(bytes.fromhex("9f01800008300030"))); st, q, qty = step(m)
check("real E65 frame: checksum accepted, no request", q == 0 and not (st & 0x40), f"stat={st}")

# optional: real 0x0B5 frames from the E65 logs (Shared/CAN-Logs/E65), if available next to the repository
LOG = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "..", "Shared", "CAN-Logs", "E65", "Log2.log")
if os.path.exists(LOG):
    real = []
    for line in open(LOG, errors="replace"):
        mt = re.match(r"\s*[\d.]+\s+\d+\s+B5\s+Rx\s+d\s+8((?:\s+[0-9A-Fa-f]{2}){8})", line)
        if mt:
            real.append(bytes(int(x, 16) for x in mt.group(1).split()))
    real = real[:20000]
    m = setup(); faults = locks = reqs = 0
    for b in real:
        put(m, list(b)); st, q, qty = step(m)
        faults += bool(st & 0x40); locks += bool(st & 8); reqs += q != 0
    check(f"{len(real)} real E65 frames: no checksum/alive fault, no lock, no request (the logs have no ST=1)",
          faults == 0 and locks == 0 and reqs == 0, f"faults={faults} locks={locks} requests={reqs}")
    m = setup(TMX=0xFFFF); bad = 0
    for b in real[:3000]:                    # force ST=1 into real frames and recompute the checksum
        f = list(b)
        f[4] = (f[4] & 0xCF) | 0x10
        f[3] = f[3] if (f[3] | ((f[4] & 15) << 8)) != 2000 else 0
        s = sum(f[1:]) + 0xB5
        f[0] = ((s & 0xFF) + (s >> 8)) & 0xFF
        put(m, f); st, q, qty = step(m)
        tar = (f[1] >> 4) | (f[2] << 4)
        adj = f[3] | ((f[4] & 15) << 8)
        exp = 0 if (tar >= 0x800 or adj >= 0x800 or adj == 2000) else q_of(min(tar, adj) >> 1)
        if st & 0x40 or st & 8:
            bad += 1
        elif q != exp and not (st & 4):
            bad += 1
    check("3000 real E65 frames with ST forced to 1: request equals MIN(target, limit)", bad == 0, f"mismatches={bad}")

print(f"{sum(results)} of {len(results)} checks passed")
sys.exit(0 if all(results) else 1)
