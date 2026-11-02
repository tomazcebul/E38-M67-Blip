"""Build the DDE41A (7787316O / Y7787646) blip patch described in Blip-Function.md, chapter 5.

Writes patched COPIES to DDE41A-RE/patch/ (the SP-Daten files and DDE41A-RE/bin stay untouched):
  7787316O_program_blip.bin   program 0x080000-0x0EFFFF (patch code at 0x0C0000, hooks H1-H3)
  Y7787646_data_blip.bin      data    0x0F0000-0x0FFFFF (calibration 0x0F7880, CAN descriptor 0x0F7900-0x0F790F)
  DDE41A_O_full_80000_blip.bin combined 512 KB image 0x080000-0x0FFFFF (stock top sector from the flash read)
  blip_patch.lst              verification listing (every byte decoded back with c166.py)

The function ships DISABLED (wcwFUN_BLP = 0, wrwBLP_MDN = 0). The EPROM checksum is NOT corrected
(see Blip-Function.md 5.5), so the images are not flashable as they are.

Assembler: a minimal two-pass encoder for the C167 instructions used below. Conditional branches use
JMPA (absolute within the segment) only, so there are no relative-range limits.
"""
import os
import sys

sys.path.insert(0, os.path.dirname(__file__))
import c166  # noqa: E402

HERE = os.path.dirname(os.path.abspath(__file__))
RE = os.path.dirname(HERE)
BIN = os.path.join(RE, "bin")
OUT = os.path.join(RE, "patch")

PROG_BASE, DATA_BASE = 0x080000, 0x0F0000
CODE_BASE = 0x0C0000
H1_ENTRY, H2_ENTRY, H3_ENTRY = 0x0C0000, 0x0C0100, 0x0C0200

CC = {"UC": 0, "Z": 2, "NZ": 3, "N": 6, "NN": 7, "C": 8, "ULT": 8, "NC": 9, "UGE": 9,
      "SGT": 10, "SLE": 11, "SLT": 12, "SGE": 13, "UGT": 14, "ULE": 15}
MDL, MDH = 0xFE0E, 0xFE0C
ZEROS = 0x8E


def lo(v):
    return v & 0xFF


def hi(v):
    return (v >> 8) & 0xFF


class Asm:
    def __init__(self, base):
        self.base = base
        self.code = bytearray()
        self.labels = {}
        self.fix = []          # (offset, label)
        self.expect = []       # (address, text) for the listing

    @property
    def pc(self):
        return self.base + len(self.code)

    def label(self, name):
        assert name not in self.labels, name
        self.labels[name] = self.pc

    def emit(self, b, text):
        self.expect.append((self.pc, text))
        self.code += bytes(b)

    def org(self, addr):
        assert addr >= self.pc, (hex(addr), hex(self.pc))
        self.code += b"\xFF" * (addr - self.pc)

    # ---- word / byte moves (R = GPR number, RL = byte register number) ----
    def mov_ri(self, r, v):    self.emit([0xE6, 0xF0 | r, lo(v), hi(v)], f"MOV R{r}, #0x{v & 0xFFFF:04X}")
    def mov_rm(self, r, m):    self.emit([0xF2, 0xF0 | r, lo(m), hi(m)], f"MOV R{r}, 0x{m:04X}")
    def mov_mr(self, m, r):    self.emit([0xF6, 0xF0 | r, lo(m), hi(m)], f"MOV 0x{m:04X}, R{r}")
    def mov_m0(self, m):       self.emit([0xF6, ZEROS, lo(m), hi(m)], f"MOV 0x{m:04X}, ZEROS")
    def mov_rr(self, a, b):    self.emit([0xF0, a << 4 | b], f"MOV R{a}, R{b}")
    def movb_rm(self, rl, m):  self.emit([0xF3, 0xF0 | 2 * rl, lo(m), hi(m)], f"MOVB RL{rl}, 0x{m:04X}")
    def movb_mr(self, m, rl):  self.emit([0xF7, 0xF0 | 2 * rl, lo(m), hi(m)], f"MOVB 0x{m:04X}, RL{rl}")
    def movb_m0(self, m):      self.emit([0xF7, ZEROS, lo(m), hi(m)], f"MOVB 0x{m:04X}, ZEROS")
    def movb_ri(self, rl, v):  self.emit([0xE7, 0xF0 | 2 * rl, v & 0xFF, 0], f"MOVB RL{rl}, #0x{v & 0xFF:02X}")
    def movbz_rm(self, r, m):  self.emit([0xC2, 0xF0 | r, lo(m), hi(m)], f"MOVBZ R{r}, 0x{m:04X}")
    def movb_rind(self, rl, r, d):
        self.emit([0xF4, (2 * rl) << 4 | r, lo(d), hi(d)], f"MOVB RL{rl}, [R{r}+#0x{d:04X}]")
    def movbz_rr(self, r, rl): self.emit([0xC0, (2 * rl) << 4 | r], f"MOVBZ R{r}, RL{rl}")

    # ---- ALU ----
    def _alu_ri(self, g, nm, r, v): self.emit([g | 6, 0xF0 | r, lo(v), hi(v)], f"{nm} R{r}, #0x{v & 0xFFFF:04X}")
    def _alu_rm(self, g, nm, r, m): self.emit([g | 2, 0xF0 | r, lo(m), hi(m)], f"{nm} R{r}, 0x{m:04X}")
    def _alu_rr(self, g, nm, a, b): self.emit([g, a << 4 | b], f"{nm} R{a}, R{b}")
    def add_ri(self, r, v): self._alu_ri(0x00, "ADD", r, v)
    def add_rm(self, r, m): self._alu_rm(0x00, "ADD", r, m)
    def add_rr(self, a, b): self._alu_rr(0x00, "ADD", a, b)
    def sub_rm(self, r, m): self._alu_rm(0x20, "SUB", r, m)
    def sub_rr(self, a, b): self._alu_rr(0x20, "SUB", a, b)
    def cmp_ri(self, r, v): self._alu_ri(0x40, "CMP", r, v)
    def cmp_rm(self, r, m): self._alu_rm(0x40, "CMP", r, m)
    def cmp_rr(self, a, b): self._alu_rr(0x40, "CMP", a, b)
    def and_ri(self, r, v): self._alu_ri(0x60, "AND", r, v)
    def or_ri(self, r, v):  self._alu_ri(0x70, "OR", r, v)
    def cmpb_ri(self, rl, v): self.emit([0x47, 0xF0 | 2 * rl, v & 0xFF, 0], f"CMPB RL{rl}, #0x{v & 0xFF:02X}")
    def cmpb_rm(self, rl, m): self.emit([0x43, 0xF0 | 2 * rl, lo(m), hi(m)], f"CMPB RL{rl}, 0x{m:04X}")
    def neg(self, r):        self.emit([0x81, r << 4], f"NEG R{r}")
    def ashr_rr(self, a, b): self.emit([0xAC, a << 4 | b], f"ASHR R{a}, R{b}")
    def mulu(self, a, b):    self.emit([0x1B, a << 4 | b], f"MULU R{a}, R{b}")
    def divlu(self, r):      self.emit([0x7B, r << 4 | r], f"DIVLU R{r}")

    # ---- stack / control ----
    def push(self, r): self.emit([0xEC, 0xF0 | r], f"PUSH R{r}")
    def pop(self, r):  self.emit([0xFC, 0xF0 | r], f"POP R{r}")
    def rets(self):    self.emit([0xDB, 0x00], "RETS")
    def calls(self, t): self.emit([0xDA, t >> 16, lo(t), hi(t)], f"CALLS 0x{t:06X}")

    def jmpa(self, cc, label):
        self.fix.append((len(self.code), label))
        self.emit([0xEA, CC[cc] << 4, 0, 0], f"JMPA cc_{cc}, {label}")

    def resolve(self):
        for off, name in self.fix:
            t = self.labels[name]
            assert t >> 16 == self.base >> 16, f"{name} not in segment"
            self.code[off + 2], self.code[off + 3] = lo(t), hi(t)


# --------------------------------------------------------------------------
# RAM (XRAM 0xE780-0xE7DF, see Blip-Function.md 5.1) and calibration (DPP1)
# --------------------------------------------------------------------------
RXB5, RXC5, RXT5 = 0xE780, 0xE78A, 0xE78C          # TORQUE_GEARBX 0x0B5 buffer (E65 layout), poll counter, time
STAT, NLOCK = 0xE78E, 0xE78F
QREQ, Q, T, TOLOCK, INIT, MREQ = 0xE790, 0xE792, 0xE794, 0xE796, 0xE798, 0xE79A
GLATCH, SPREV, ARM, STPREV, ARMED, EDEB, EERR, ALVPREV, ALVCNT, STOLD, EDEB2 = (
    0xE7C0, 0xE7C1, 0xE7C2, 0xE7C4, 0xE7C5, 0xE7C8, 0xE7C9, 0xE7CA, 0xE7CB, 0xE7CC, 0xE7CD)
INIT_MAGIC = 0x5AA5

CAL = 0x7880                                         # 16-bit via DPP1 -> 0x0F7880
C = {k: CAL + o for k, o in dict(
    FUN=0x00, NMN=0x02, NMX=0x04, TMN=0x06, VMN=0x08, MMX=0x0A, TMX=0x0C, RAMP=0x0E,
    MDN=0x10, LOCK=0x12, ADJD=0x14, CHK=0x16, ALVN=0x18, XEGS=0x1A, TARM=0x1C,
    EDEBC=0x1E, EMX=0x20).items()}
DESC5 = 0x7900

# Calibration values. Function OFF and MD_NORM unknown -> the patch is inert until calibrated.
CAL_VALUES = dict(
    FUN=0,       # wcwFUN_BLP          0 = off
    NMN=900,     # wrwBLP_NMN          rpm
    NMX=3800,    # wrwBLP_NMX          rpm, ceiling E3 (placeholder: set from Max RPM and the shift maps)
    TMN=3331,    # wrwBLP_TMN          anmWTF raw (0.1 K, -273.14) = 60 degC
    VMN=500,     # wrwBLP_VMN          0.01 km/h = 5 km/h
    MMX=3000,    # wrwBLP_MMX          0.01 mm3 = 30 mm3/stroke
    TMX=30,      # wrwBLP_TMX          task cycles (600 ms at an assumed 20 ms period, to measure)
    RAMP=200,    # wrwBLP_RAMP         0.01 mm3 per call
    MDN=0,       # wrwBLP_MDN          MD_NORM in Nm (DDE2 MUL_COD 3 x 16), 0 = not set -> off
    LOCK=3,      # wrwBLP_LOCK         duration events until lock
    ADJD=2000,   # wrwBLP_ADJD         TORQ_TAR_ADJR_POS_EGS default value (raw, 0.5 Nm) = 1000 Nm: not a request
    CHK=1,       # wcwBLP_CHK          1 = check checksum and alive counter (BMW), 0 = sender has none
    ALVN=5,      # wrwBLP_ALVN         polls with an unchanged alive counter until fault
    XEGS=0,      # wcwBLP_XEGS         1 = extra check E2: EGS1 confirms a downshift (off until logged)
    TARM=15,     # wrwBLP_TARM         E2 task cycles
    EDEBC=3,     # wrwBLP_EDEB         debounce cycles
    EMX=3,       # wrwBLP_EMX          integrity errors until lock
)
TOUT = 0x0A      # receive timeout in time-base ticks (EGS1 uses 0x32); about 3 x 10 ms, to set after measuring


def descriptor(obj, can_id, timeout=TOUT):
    arb = can_id << 5
    return bytes([0x01, timeout, 0x01] + [0] * 8 + [obj << 4, 0x08, hi(arb), lo(arb), 0x80])


# existing firmware entry points
SUB_097C14 = 0x097C14      # configure on-chip CAN object (R0 = descriptor)
SUB_097BE0 = 0x097BE0      # original last call in sub_099802
SUB_097E8E = 0x097E8E      # receive helper (R6 desc, R1 buf, RL7 counter, R9 time)
T_NOW = 0xF940             # receive time base
EGS1_PTR = 0xD656          # pointer to the EGS1 copy (byte 0 gear/S_SCHALT, byte 3 MD_IND_GS)
DZMNMIT, ANMWTF, FGMFGAKT = 0xC0A8, 0xC086, 0xC0A0
MD_IND_NE = 0xC125         # DDE1 transmit buffer 0xC124, byte 1
QTY, BI_SOLL, C480 = 0xC43A, 0xC40A, 0xC480

OBJECTS = [  # (descriptor, buffer, counter, time)
    (DESC5, RXB5, RXC5, RXT5),
]


def build():
    a = Asm(CODE_BASE)

    # ===== H1: end of sub_099802 (CAN init) =====
    a.org(H1_ENTRY)
    a.label("blp_can_init")
    for desc, buf, cnt, tim in OBJECTS:
        a.mov_ri(0, desc)
        a.calls(SUB_097C14)
        a.movb_rm(1, desc)            # poll counter reload = descriptor byte 0
        a.movb_mr(cnt, 1)
        a.mov_rm(1, T_NOW)
        a.mov_mr(tim, 1)
    for m in (Q, T, QREQ, MREQ, ARM):
        a.mov_m0(m)
    for m in (TOLOCK, NLOCK, EERR, EDEB, EDEB2, ARMED, SPREV, STPREV, STOLD, ALVPREV, ALVCNT, STAT):
        a.movb_m0(m)
    a.mov_ri(1, INIT_MAGIC)
    a.mov_mr(INIT, 1)
    a.calls(SUB_097BE0)               # original instruction
    a.rets()

    # ===== H2: fn_097F10 receive task, object 5 replaced =====
    a.org(H2_ENTRY)
    a.label("blp_can_rx")
    a.calls(SUB_097E8E)               # original: object 5
    a.push(7)
    a.push(9)
    a.mov_rm(4, INIT)
    a.cmp_ri(4, INIT_MAGIC)
    a.jmpa("NZ", "rx_done")
    for desc, buf, cnt, tim in OBJECTS:
        a.mov_ri(6, desc)
        a.mov_ri(1, buf)
        a.movb_rm(7, cnt)
        a.mov_rm(9, tim)
        a.calls(SUB_097E8E)
        a.movb_mr(cnt, 7)
        a.mov_mr(tim, 9)
    a.label("rx_done")
    a.pop(9)
    a.pop(7)
    a.rets()

    # ===== H3: fn_0BB868 at 0x0BC61C =====
    # in : QTY = quantity after EGS1 minimum, BI_SOLL = mroBI_SOLL ; out: QTY = MAX(QTY, wroM_EBLIP)
    # regs: R6 = request torque [Nm], RL7 = status, R5 = EGS1 pointer, R3 = gear
    a.org(H3_ENTRY)
    a.label("blp_main")
    a.push(6)
    a.push(7)
    a.movb_ri(7, 0)
    a.mov_rm(4, INIT);   a.cmp_ri(4, INIT_MAGIC); a.jmpa("NZ", "blp_off")
    a.mov_rm(4, C["FUN"]); a.cmp_ri(4, 0);        a.jmpa("Z", "blp_off")
    a.mov_rm(4, C["MDN"]); a.cmp_ri(4, 0);        a.jmpa("Z", "blp_off")
    a.movbz_rm(4, NLOCK);  a.cmp_rm(4, C["LOCK"]); a.jmpa("UGE", "blp_locked")
    a.movbz_rm(4, EERR);   a.cmp_rm(4, C["EMX"]);  a.jmpa("UGE", "blp_locked")

    # E2 (part 1): EGS1 shift state and gear latch, always updated
    a.mov_rm(5, EGS1_PTR)
    a.movb_rind(2, 5, 0)              # RL2 = EGS1 byte 0
    a.movbz_rr(3, 2)
    a.and_ri(3, 0x0007)               # R3 = GANG_INF
    a.movbz_rr(4, 2)
    a.and_ri(4, 0x0008)               # S_SCHALT
    a.jmpa("NZ", "e3_shift")
    a.movb_mr(GLATCH, 3)              # RL3 = GANG_INF
    a.movb_m0(SPREV)
    a.movb_m0(ARMED)
    a.movb_m0(STPREV)
    a.mov_rm(4, C["XEGS"]); a.cmp_ri(4, 0); a.jmpa("NZ", "blp_norq")    # E2 on: no shift -> no blip
    a.jmpa("UC", "e2p1_done")
    a.label("e3_shift")
    a.movbz_rm(4, SPREV); a.cmp_ri(4, 0); a.jmpa("NZ", "e3_running")
    a.mov_m0(ARM)
    a.movb_ri(4, 1); a.movb_mr(SPREV, 4)
    a.label("e3_running")
    a.mov_rm(4, ARM); a.cmp_ri(4, 0xFFFF); a.jmpa("Z", "e3_armsat")
    a.add_ri(4, 1); a.mov_mr(ARM, 4)
    a.label("e3_armsat")
    a.label("e2p1_done")

    # 2. message 0x0B5 present (status bit 2 = default data)
    a.movbz_rm(4, RXB5 + 8); a.and_ri(4, 0x0004); a.jmpa("NZ", "blp_missing")

    # BMW checksum and alive counter (switchable): E65 TORQUE_GEARBX 0x0B5
    #   chk = fold8(sum(bytes 1..7) + 0xB5 + 0x00), alive = byte 1 low nibble, 0..14, counts up
    a.mov_rm(4, C["CHK"]); a.cmp_ri(4, 0); a.jmpa("Z", "chk_done")
    a.mov_ri(4, 0xB5)
    for i in range(1, 8):
        a.movbz_rm(1, RXB5 + i); a.add_rr(4, 1)
    a.mov_rr(2, 4)
    a.mov_ri(1, 8); a.ashr_rr(2, 1)
    a.and_ri(4, 0x00FF); a.add_rr(4, 2); a.and_ri(4, 0x00FF)
    a.movbz_rm(1, RXB5); a.cmp_rr(4, 1); a.jmpa("NZ", "blp_chkfail")
    a.movbz_rm(4, RXB5 + 1); a.and_ri(4, 0x000F)                     # ALIV_TORQ_EGS
    a.cmp_ri(4, 0x000F); a.jmpa("Z", "blp_chkfail")                  # 0xF is never sent
    a.movbz_rm(1, ALVPREV); a.cmp_rr(4, 1); a.jmpa("Z", "alv_same")
    a.movb_mr(ALVPREV, 4)
    a.movb_m0(ALVCNT)
    a.jmpa("UC", "chk_done")
    a.label("alv_same")
    a.movbz_rm(4, ALVCNT); a.add_ri(4, 1); a.movb_mr(ALVCNT, 4)
    a.cmp_rm(4, C["ALVN"]); a.jmpa("UGT", "blp_chkfail")
    a.label("chk_done")
    a.movb_m0(EDEB2)

    # 3. request: ST_TORQ_TAR_EGS = 1 (increase); 0, 2 (decrease, EGS1 carries the reduction) and 3: none
    a.movbz_rm(4, RXB5 + 4)
    a.and_ri(4, 0x0030)
    a.mov_ri(1, 4); a.ashr_rr(4, 1)                                  # R4 = ST_TORQ_TAR_EGS
    a.movbz_rm(2, STPREV); a.movb_mr(STOLD, 2)                       # previous status for E2
    a.movb_mr(STPREV, 4)
    a.cmp_ri(4, 1); a.jmpa("NZ", "blp_norq")
    # TORQ_TAR_EGS: bits 12-23 (byte 1 high nibble, byte 2), 0.5 Nm; 0x800 = invalid, >= 0x800 negative
    a.movbz_rm(6, RXB5 + 2)
    a.mov_ri(1, 16); a.mulu(6, 1); a.mov_rm(6, MDL)
    a.movbz_rm(1, RXB5 + 1); a.mov_ri(2, 4); a.ashr_rr(1, 2); a.add_rr(6, 1)
    a.cmp_ri(6, 0x0800); a.jmpa("UGE", "blp_norq")
    # TORQ_TAR_ADJR_POS_EGS: bits 24-35 (byte 3, byte 4 low nibble); invalid, negative or default: no request
    a.movbz_rm(1, RXB5 + 4); a.and_ri(1, 0x000F)
    a.mov_ri(2, 256); a.mulu(1, 2); a.mov_rm(1, MDL)
    a.movbz_rm(2, RXB5 + 3); a.add_rr(1, 2)
    a.cmp_ri(1, 0x0800); a.jmpa("UGE", "blp_norq")
    a.cmp_rm(1, C["ADJD"]); a.jmpa("Z", "blp_norq")
    a.cmp_rr(6, 1); a.jmpa("ULE", "rq_min")                          # MIN(target, limit)
    a.mov_rr(6, 1)
    a.label("rq_min")
    a.mov_ri(1, 1); a.ashr_rr(6, 1)                                  # 0.5 Nm -> Nm
    a.cmp_ri(6, 0); a.jmpa("SLE", "blp_norq")
    a.cmp_ri(6, 2000); a.jmpa("SLE", "rq_lim_ok")
    a.mov_ri(6, 2000)                 # keeps the MULU/DIVLU below in range
    a.label("rq_lim_ok")
    a.mov_mr(MREQ, 6)

    # E2 (part 2, switchable): request must start inside the arming window after S_SCHALT, downshift only
    a.mov_rm(4, C["XEGS"]); a.cmp_ri(4, 0); a.jmpa("Z", "e2_off")
    a.movbz_rm(2, STOLD)
    a.cmp_ri(2, 1); a.jmpa("Z", "e3_armed_chk")       # already running
    a.mov_rm(4, ARM); a.cmp_rm(4, C["TARM"]); a.jmpa("UGT", "blp_e2efail")
    a.movb_ri(4, 1); a.movb_mr(ARMED, 4)
    a.label("e3_armed_chk")
    a.movbz_rm(4, ARMED); a.cmp_ri(4, 0); a.jmpa("Z", "blp_e2efail")
    a.movbz_rm(4, GLATCH); a.cmp_rr(3, 4); a.jmpa("UGE", "blp_e2efail")
    a.label("e2_off")

    # 4. EGS1 reduction has priority
    a.movb_rind(2, 5, 3)              # RL2 = MD_IND_GS
    a.cmpb_ri(2, 0xFF); a.jmpa("NZ", "blp_window")

    # 5. operating window
    a.mov_rm(4, DZMNMIT)
    a.cmp_rm(4, C["NMN"]); a.jmpa("ULT", "blp_window")
    a.mov_rm(4, ANMWTF);   a.cmp_rm(4, C["TMN"]); a.jmpa("ULT", "blp_window")
    a.mov_rm(4, FGMFGAKT); a.cmp_rm(4, C["VMN"]); a.jmpa("ULT", "blp_window")
    a.movb_m0(EDEB)                   # E2 passed: restart its debounce

    # E3: engine speed ceiling, cut immediately at or above wrwBLP_NMX
    a.mov_rm(4, DZMNMIT)
    a.cmp_rm(4, C["NMX"]); a.jmpa("ULT", "e3_ok")
    a.movb_ri(7, 0x80)
    a.mov_m0(Q)
    a.jmpa("UC", "blp_apply")
    a.label("e3_ok")

    # 6. maximum duration
    a.movbz_rm(4, TOLOCK); a.cmp_ri(4, 0); a.jmpa("NZ", "blp_tmowait")
    a.mov_rm(4, T); a.cmp_rm(4, C["TMX"]); a.jmpa("UGE", "blp_timeout")
    a.add_ri(4, 1); a.mov_mr(T, 4)

    # quantity: Nm -> MD scale (x 255 / MD_NORM, max 254) -> x mroBI_SOLL / 500, max wrwBLP_MMX
    a.mov_ri(1, 255)
    a.mulu(6, 1)
    a.mov_rm(1, C["MDN"])
    a.divlu(1)
    a.mov_rm(4, MDL)
    a.cmp_ri(4, 254); a.jmpa("ULE", "q_md_ok")
    a.mov_ri(4, 254)
    a.label("q_md_ok")
    a.mov_rm(1, BI_SOLL)
    a.mulu(4, 1)
    a.mov_ri(1, 500)
    a.divlu(1)
    a.mov_rm(4, MDL)
    a.cmp_rm(4, C["MMX"]); a.jmpa("ULE", "q_ok")
    a.mov_rm(4, C["MMX"])
    a.label("q_ok")
    a.mov_mr(QREQ, 4)
    a.mov_mr(Q, 4)                    # permitted: pass through, no ramp
    a.movb_ri(7, 0x01)
    a.jmpa("UC", "blp_apply")

    a.label("blp_norq")               # request ended -> abrupt end
    a.mov_m0(T)
    a.movb_m0(TOLOCK)
    a.mov_m0(Q)
    a.jmpa("UC", "blp_apply")

    a.label("blp_timeout")
    a.movb_ri(4, 1); a.movb_mr(TOLOCK, 4)
    a.movb_rm(4, NLOCK); a.emit([0x07, 0xF8, 0x01, 0x00], "ADDB RL4, #0x01"); a.movb_mr(NLOCK, 4)
    a.label("blp_tmowait")
    a.movb_ri(7, 0x04)
    a.jmpa("UC", "blp_withdraw")

    a.label("blp_locked")
    a.movb_ri(7, 0x08)
    a.jmpa("UC", "blp_withdraw")

    a.label("blp_missing")
    a.movb_ri(7, 0x20)
    a.jmpa("UC", "blp_withdraw")

    a.label("blp_chkfail")            # checksum / alive counter failed (own debounce)
    a.movb_ri(7, 0x40)
    a.movb_rm(4, EDEB2); a.emit([0x07, 0xF8, 0x01, 0x00], "ADDB RL4, #0x01"); a.movb_mr(EDEB2, 4)
    a.movbz_rm(4, EDEB2); a.cmp_rm(4, C["EDEBC"]); a.jmpa("ULT", "blp_withdraw")
    a.movb_m0(EDEB2)
    a.movb_rm(4, EERR); a.emit([0x07, 0xF8, 0x01, 0x00], "ADDB RL4, #0x01"); a.movb_mr(EERR, 4)
    a.jmpa("UC", "blp_withdraw")

    a.label("blp_e2efail")
    a.movb_ri(7, 0x40)
    a.movb_rm(4, EDEB); a.emit([0x07, 0xF8, 0x01, 0x00], "ADDB RL4, #0x01"); a.movb_mr(EDEB, 4)
    a.movbz_rm(4, EDEB); a.cmp_rm(4, C["EDEBC"]); a.jmpa("ULT", "blp_withdraw")
    a.movb_m0(EDEB)
    a.movb_rm(4, EERR); a.emit([0x07, 0xF8, 0x01, 0x00], "ADDB RL4, #0x01"); a.movb_mr(EERR, 4)
    a.jmpa("UC", "blp_withdraw")

    a.label("blp_window")
    a.movb_ri(7, 0x10)
    a.label("blp_withdraw")           # permission withdrawn -> ramp to 0
    a.mov_rm(4, Q)
    a.sub_rm(4, C["RAMP"])
    a.jmpa("SGT", "wd_pos")
    a.mov_ri(4, 0)
    a.label("wd_pos")
    a.mov_mr(Q, 4)
    a.cmp_ri(4, 0); a.jmpa("Z", "blp_apply")
    a.emit([0x77, 0xFE, 0x02, 0x00], "ORB RL7, #0x02")
    a.jmpa("UC", "blp_apply")

    a.label("blp_off")
    a.mov_m0(Q)
    a.label("blp_apply")
    a.movb_mr(STAT, 7)
    a.mov_rm(4, Q)
    a.cmp_rm(4, QTY); a.jmpa("SLE", "blp_exit")
    a.mov_mr(QTY, 4)                  # MAX(quantity after EGS1 minimum, blip)
    a.label("blp_exit")
    a.pop(7)
    a.pop(6)
    a.movb_rm(4, C480)                # original instruction at 0x0BC61C
    a.rets()

    a.resolve()
    return a


HOOKS = [  # (address, original bytes, new target)
    (0x099858, bytes.fromhex("DA09E07B"), H1_ENTRY),
    (0x097FA8, bytes.fromhex("DA098E7E"), H2_ENTRY),
    (0x0BC61C, bytes.fromhex("F3F880C4"), H3_ENTRY),
]


def calls_bytes(t):
    return bytes([0xDA, t >> 16, lo(t), hi(t)])


def verify(a, prog):
    """Decode the patch code back with c166.py and compare it with what was emitted."""
    lines, errors = [], 0
    exp = dict(a.expect)
    addr, end = CODE_BASE, a.pc
    while addr < end:
        off = addr - PROG_BASE
        if prog[off] == 0xFF and addr not in exp:
            addr += 1
            continue
        ins = c166.decode(prog, off, addr)
        want = exp.get(addr)
        ok = want is not None and not ins.bad
        if ok:
            nxt = [x for x in exp if x > addr]
            nb = min(nxt) if nxt else end
            gap = prog[off + ins.size:nb - PROG_BASE]
            ok = nb == addr + ins.size or (nb > addr + ins.size and all(x == 0xFF for x in gap))
        if not ok:
            errors += 1
        lab = [k for k, v in a.labels.items() if v == addr]
        if lab:
            lines.append(f"{lab[0]}:")
        lines.append(f"  {addr:06X}: {ins.raw.hex():<8}  {ins.text():<32} ; {want or '?'}{'' if ok else '   <-- MISMATCH'}")
        addr += ins.size
    for name, t in a.labels.items():
        if t >= end:
            errors += 1
            lines.append(f"label {name} outside code")
    return lines, errors


def main():
    prog = bytearray(open(os.path.join(BIN, "7787316O_program.bin"), "rb").read())
    data = bytearray(open(os.path.join(BIN, "Y7787646_data.bin"), "rb").read())
    full = bytearray(open(os.path.join(BIN, "DDE41A_O_full_80000.bin"), "rb").read())
    assert len(prog) == 0x70000 and len(data) == 0x10000 and len(full) == 0x80000

    a = build()
    code_off = CODE_BASE - PROG_BASE
    assert all(b == 0xFF for b in prog[code_off:code_off + len(a.code)]), "patch area not erased"
    prog[code_off:code_off + len(a.code)] = a.code

    hook_lines = []
    for addr, orig, tgt in HOOKS:
        off = addr - PROG_BASE
        assert prog[off:off + 4] == orig, f"unexpected bytes at {addr:06X}"
        prog[off:off + 4] = calls_bytes(tgt)
        ins = c166.decode(prog, off, addr)
        hook_lines.append(f"  {addr:06X}: {orig.hex()} -> {prog[off:off + 4].hex()}  {ins.text()}")
        assert ins.mnem == "CALLS" and ins.target == tgt

    # calibration block and descriptors (data image, base 0x0F0000; DPP1 0x7880 -> 0x0F7880)
    cal = bytearray()
    for k, o in sorted(((k, v - CAL) for k, v in C.items()), key=lambda x: x[1]):
        assert len(cal) == o
        cal += (CAL_VALUES[k] & 0xFFFF).to_bytes(2, "little")
    descs = descriptor(9, 0x0B5)
    for start, blob in ((0x7880, bytes(cal)), (0x7900, descs)):
        assert all(b == 0xC3 for b in data[start:start + len(blob)]), "calibration area not free"
        data[start:start + len(blob)] = blob

    full[0:0x70000] = prog
    full[0x70000:0x7C000] = data[0x0000:0xC000]      # data area 0x0F0000-0x0FBFFF; top sector stays stock

    lines, errors = verify(a, prog)
    os.makedirs(OUT, exist_ok=True)
    open(os.path.join(OUT, "7787316O_program_blip.bin"), "wb").write(prog)
    open(os.path.join(OUT, "Y7787646_data_blip.bin"), "wb").write(data)
    open(os.path.join(OUT, "DDE41A_O_full_80000_blip.bin"), "wb").write(full)

    with open(os.path.join(OUT, "blip_patch.lst"), "w", encoding="utf-8") as f:
        f.write("; DDE41A blip patch - generated by tools/blip_patch.py (see Blip-Function.md ch. 5)\n")
        f.write("; Function DISABLED (wcwFUN_BLP = 0, wrwBLP_MDN = 0). EPROM checksum NOT corrected.\n\n")
        f.write("; Hooks\n" + "\n".join(hook_lines) + "\n\n")
        f.write(f"; Calibration 0x0F7880 ({len(cal)} bytes)\n")
        for k, v in sorted(C.items(), key=lambda x: x[1]):
            f.write(f";   0x0F{v:04X}  {k:<6} = {CAL_VALUES[k]}\n")
        f.write("; CAN descriptor 0x0F7900 (obj 9, 0x0B5)\n")
        f.write(f";   0x0F7900: {descs.hex(' ')}\n")
        f.write(f"\n; Code 0x{CODE_BASE:06X}-0x{a.pc - 1:06X} ({len(a.code)} bytes), decoded back with c166.py\n")
        f.write("\n".join(lines) + "\n")

    diff_p = sum(1 for x, y in zip(prog, open(os.path.join(BIN, "7787316O_program.bin"), "rb").read()) if x != y)
    diff_d = sum(1 for x, y in zip(data, open(os.path.join(BIN, "Y7787646_data.bin"), "rb").read()) if x != y)
    print(f"code {len(a.code)} bytes at 0x{CODE_BASE:06X}, {len(a.expect)} instructions, "
          f"verification errors: {errors}")
    print(f"program bytes changed: {diff_p}, data bytes changed: {diff_d}")
    print("\n".join(hook_lines))
    print(f"output: {OUT}")
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main())
