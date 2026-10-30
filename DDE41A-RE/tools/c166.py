"""Infineon/Siemens C166/C167 instruction decoder.

Written from the C16x Family Instruction Set Manual; operand formatting
cross-checked against the opcode table of hn/c166-dis (c166_is_ref.txt).

decode(buf, off, addr) -> Insn
  buf  : bytes-like image
  off  : offset of instruction in buf
  addr : 24-bit CPU address of the instruction (for relative targets/segment)
"""
from dataclasses import dataclass, field

CC = ["cc_UC", "cc_NET", "cc_Z", "cc_NZ", "cc_V", "cc_NV", "cc_N", "cc_NN",
      "cc_C", "cc_NC", "cc_SGT", "cc_SLE", "cc_SLT", "cc_SGE", "cc_UGT", "cc_ULE"]

# C167CR SFRs, keyed by 8-bit short address (SFR = 0xFE00 + 2*RR)
SFR = {
    0x00: "DPP0", 0x01: "DPP1", 0x02: "DPP2", 0x03: "DPP3", 0x04: "CSP", 0x06: "MDH",
    0x07: "MDL", 0x08: "CP", 0x09: "SP", 0x0A: "STKOV", 0x0B: "STKUN", 0x0C: "ADDRSEL1",
    0x0D: "ADDRSEL2", 0x0E: "ADDRSEL3", 0x0F: "ADDRSEL4", 0x18: "PW0", 0x19: "PW1",
    0x1A: "PW2", 0x1B: "PW3", 0x20: "T2", 0x21: "T3", 0x22: "T4", 0x23: "T5", 0x24: "T6",
    0x25: "CAPREL", 0x28: "T0", 0x29: "T1", 0x2A: "T0REL", 0x2B: "T1REL",
    0x50: "ADDAT", 0x57: "WDT", 0x58: "S0TBUF", 0x59: "S0RBUF", 0x5A: "S0BG",
    0x5B: "SSCTB", 0x5C: "SSCRB", 0x5D: "SSCBR",
    0x80: "P0L", 0x81: "P0H", 0x82: "P1L", 0x83: "P1H", 0x86: "BUSCON0", 0x87: "MDC",
    0x88: "PSW", 0x89: "SYSCON", 0x8A: "BUSCON1", 0x8B: "BUSCON2", 0x8C: "BUSCON3",
    0x8D: "BUSCON4", 0x8E: "ZEROS", 0x8F: "ONES", 0x98: "PWMCON0", 0x99: "PWMCON1",
    0xA0: "T2CON", 0xA1: "T3CON", 0xA2: "T4CON", 0xA3: "T5CON", 0xA4: "T6CON",
    0xA8: "T01CON", 0xA9: "CCM0", 0xAA: "CCM1", 0xAB: "CCM2", 0xAC: "CCM3",
    0xB0: "T2IC", 0xB1: "T3IC", 0xB2: "T4IC", 0xB3: "T5IC", 0xB4: "T6IC", 0xB5: "CRIC",
    0xB6: "S0TIC", 0xB7: "S0RIC", 0xB8: "S0EIC", 0xB9: "SSCTIC", 0xBA: "SSCRIC",
    0xBB: "SSCEIC", 0xCC: "ADCIC", 0xCD: "ADEIC", 0xCE: "T0IC", 0xCF: "T1IC",
    0xD0: "ADCON", 0xD1: "P5", 0xD2: "P5DIDIS", 0xD6: "TFR", 0xD7: "WDTCON",
    0xD8: "S0CON", 0xD9: "SSCCON", 0xE0: "P2", 0xE1: "DP2", 0xE2: "P3", 0xE3: "DP3",
    0xE4: "P4", 0xE5: "DP4", 0xE6: "P6", 0xE7: "DP6", 0xE8: "P7", 0xE9: "DP7",
    0xEA: "P8", 0xEB: "DP8",
}
for i in range(16):
    SFR.setdefault(0x40 + i, f"CC{i}")
    SFR.setdefault(0x30 + i, f"CC{16 + i}")
    SFR.setdefault(0xBC + i, f"CC{i}IC")
for i in range(8):
    SFR.setdefault(0x60 + i, f"PECC{i}")

LEN4 = set()
for base in (0x00, 0x10, 0x20, 0x30, 0x50, 0x60, 0x70):
    LEN4 |= {base + 2, base + 3, base + 4, base + 5, base + 6, base + 7}
LEN4 |= {0x42, 0x43, 0x46, 0x47}
LEN4 |= {0x0A, 0x1A, 0x2A, 0x3A, 0x4A, 0x5A, 0x6A, 0x7A, 0x8A, 0x9A, 0xAA, 0xBA}
LEN4 |= {0x82, 0x86, 0x92, 0x96, 0xA2, 0xA6, 0xB2, 0xB6}
LEN4 |= {0x84, 0x94, 0xA4, 0xB4, 0xC4, 0xD4, 0xE4, 0xF4}
LEN4 |= {0xC2, 0xC5, 0xD2, 0xD5, 0xC6, 0xD6, 0xCA, 0xDA, 0xEA, 0xFA, 0xE2, 0xE6, 0xE7}
LEN4 |= {0xF2, 0xF3, 0xF6, 0xF7, 0xD7, 0x87, 0x97, 0xA5, 0xA7, 0xB5, 0xB7}

ALU = {0x00: "ADD", 0x10: "ADDC", 0x20: "SUB", 0x30: "SUBC", 0x40: "CMP",
       0x50: "XOR", 0x60: "AND", 0x70: "OR"}
SHIFT = {0x0C: "ROL", 0x2C: "ROR", 0x4C: "SHL", 0x6C: "SHR", 0xAC: "ASHR"}


@dataclass
class Insn:
    addr: int
    size: int
    mnem: str
    ops: str = ""
    raw: bytes = b""
    flow: str = "seq"          # seq, jmp, cjmp, call, ret, ijmp, icall, stop, bad
    target: int | None = None  # resolved code target (24-bit)
    mem: list = field(default_factory=list)   # (16-bit address, 'r'|'w'|'rw', byte?)
    imm: list = field(default_factory=list)   # 16-bit immediates
    ext: tuple | None = None   # ('p'|'s'|'pr'|'sr'|'r', value|None, count)
    regw: int | None = None    # destination reg (raw RR) for MOV reg,#imm
    bad: bool = False

    def text(self):
        return f"{self.mnem:<7} {self.ops}".rstrip()


def rw(n):
    return f"R{n}"


def rb(n):
    return f"RL{n >> 1}" if n % 2 == 0 else f"RH{n >> 1}"


def regw(rr):
    if rr >= 0xF0:
        return rw(rr & 0xF)
    return SFR.get(rr, f"SFR_{0xFE00 + 2 * rr:04X}")


def regb(rr):
    if rr >= 0xF0:
        return rb(rr & 0xF)
    n = SFR.get(rr)
    return n if n else f"SFR_{0xFE00 + 2 * rr:04X}"


def bitoff(qq):
    if qq < 0x80:
        return f"0x{0xFD00 + 2 * qq:04X}"
    if qq < 0xF0:
        return SFR.get(qq, f"SFR_{0xFF00 + 2 * (qq - 0x80):04X}")
    return rw(qq & 0xF)


def bitaddr(qq, q):
    return f"{bitoff(qq)}.{q}"


def m16(v):
    return f"0x{v:04X}"


def decode(buf, off, addr):
    op = buf[off]
    size = 4 if op in LEN4 else 2
    if off + size > len(buf):
        return Insn(addr, 1, "??", raw=bytes(buf[off:off + 1]), flow="bad", bad=True)
    b = bytes(buf[off:off + size])
    b1 = b[1]
    hi, lo = b1 >> 4, b1 & 0xF
    w = (b[3] << 8 | b[2]) if size == 4 else 0
    seg = addr & 0xFF0000
    nxt = addr + size
    I = Insn(addr, size, "", raw=b)

    def rel(r):
        r = r - 256 if r >= 128 else r
        return (seg | ((nxt + 2 * r) & 0xFFFF))

    g, sub = op & 0xF0, op & 0x0F
    # ALU group
    if g in ALU and sub <= 9 and not (g == 0x40 and sub in (4, 5)):
        name = ALU[g] + ("B" if sub & 1 else "")
        R = rb if sub & 1 else rw
        REG = regb if sub & 1 else regw
        if sub in (0, 1):
            I.mnem, I.ops = name, f"{R(hi)}, {R(lo)}"
        elif sub in (2, 3):
            I.mnem, I.ops = name, f"{REG(b1)}, {m16(w)}"
            I.mem.append((w, "r", sub & 1))
        elif sub in (4, 5):
            I.mnem, I.ops = name, f"{m16(w)}, {REG(b1)}"
            I.mem.append((w, "rw", sub & 1))
        elif sub == 6:
            I.mnem, I.ops = name, f"{REG(b1)}, #0x{w:04X}"
            I.imm.append(w)
        elif sub == 7:
            I.mnem, I.ops = name, f"{REG(b1)}, #0x{b[2]:02X}"
        elif sub in (8, 9):
            if lo & 0x8:
                inc = "+" if lo & 0x4 else ""
                I.mnem, I.ops = name, f"{R(hi)}, [{rw(lo & 3)}{inc}]"
            else:
                I.mnem, I.ops = name, f"{R(hi)}, #{lo & 7}"
        return I
    if op in SHIFT:
        I.mnem, I.ops = SHIFT[op], f"{rw(hi)}, {rw(lo)}"
        return I
    if op - 0x10 in SHIFT:
        I.mnem, I.ops = SHIFT[op - 0x10], f"{rw(lo)}, #{hi}"
        return I
    if sub == 0xE or sub == 0xF:
        I.mnem = "BCLR" if sub == 0xE else "BSET"
        I.ops = bitaddr(b1, op >> 4)
        return I
    if sub == 0xD:
        I.mnem, I.ops = "JMPR", f"{CC[op >> 4]}, 0x{rel(b1):06X}"
        I.target = rel(b1)
        I.flow = "jmp" if op >> 4 == 0 else "cjmp"
        return I
    if op in (0x4A, 0x3A, 0x6A, 0x5A, 0x7A, 0x2A):
        nm = {0x4A: "BMOV", 0x3A: "BMOVN", 0x6A: "BAND", 0x5A: "BOR", 0x7A: "BXOR", 0x2A: "BCMP"}[op]
        I.mnem, I.ops = nm, f"{bitaddr(b[2], b[3] & 0xF)}, {bitaddr(b1, b[3] >> 4)}"
        return I
    if op in (0x0A, 0x1A):
        I.mnem = "BFLDL" if op == 0x0A else "BFLDH"
        I.ops = f"{bitoff(b1)}, #0x{b[2]:02X}, #0x{b[3]:02X}"
        return I
    if op in (0x8A, 0x9A, 0xAA, 0xBA):
        I.mnem = {0x8A: "JB", 0x9A: "JNB", 0xAA: "JBC", 0xBA: "JNBS"}[op]
        t = rel(b[2])
        I.ops = f"{bitaddr(b1, b[3] >> 4)}, 0x{t:06X}"
        I.target, I.flow = t, "cjmp"
        return I
    if op in (0xEA, 0xCA):
        t = seg | w
        c = hi
        I.mnem = "JMPA" if op == 0xEA else "CALLA"
        I.ops = f"{CC[c]}, 0x{t:06X}"
        I.target = t
        I.flow = ("jmp" if c == 0 else "cjmp") if op == 0xEA else "call"
        return I
    if op in (0xFA, 0xDA):
        t = (b1 << 16) | w
        I.mnem = "JMPS" if op == 0xFA else "CALLS"
        I.ops = f"0x{t:06X}"
        I.target, I.flow = t, ("jmp" if op == 0xFA else "call")
        return I
    if op == 0x9C:
        I.mnem, I.ops, I.flow = "JMPI", f"{CC[hi]}, [{rw(lo)}]", ("ijmp" if hi == 0 else "seq")
        return I
    if op == 0xAB:
        I.mnem, I.ops, I.flow = "CALLI", f"{CC[hi]}, [{rw(lo)}]", "icall"
        return I
    if op == 0xBB:
        t = rel(b1)
        I.mnem, I.ops, I.target, I.flow = "CALLR", f"0x{t:06X}", t, "call"
        return I
    if op == 0xE2:
        t = seg | w
        I.mnem, I.ops, I.target, I.flow = "PCALL", f"{regw(b1)}, 0x{t:06X}", t, "call"
        return I
    simple = {(0xCB, 0x00): "RET", (0xDB, 0x00): "RETS", (0xFB, 0x88): "RETI", (0xCC, 0x00): "NOP"}
    if (op, b1) in simple:
        I.mnem = simple[(op, b1)]
        I.flow = "seq" if op == 0xCC else "ret"
        return I
    if op == 0xEB:
        I.mnem, I.ops, I.flow = "RETP", regw(b1), "ret"
        return I
    if op == 0x9B:
        I.mnem, I.ops = "TRAP", f"#0x{b1 >> 1:02X}"
        return I
    if op == 0xEC:
        I.mnem, I.ops = "PUSH", regw(b1)
        return I
    if op == 0xFC:
        I.mnem, I.ops = "POP", regw(b1)
        return I
    if op == 0xC6:
        I.mnem, I.ops = "SCXT", f"{regw(b1)}, #0x{w:04X}"
        I.imm.append(w)
        return I
    if op == 0xD6:
        I.mnem, I.ops = "SCXT", f"{regw(b1)}, {m16(w)}"
        I.mem.append((w, "r", 0))
        return I
    # MOV family
    if op == 0xF0:
        I.mnem, I.ops = "MOV", f"{rw(hi)}, {rw(lo)}"; return I
    if op == 0xF1:
        I.mnem, I.ops = "MOVB", f"{rb(hi)}, {rb(lo)}"; return I
    if op == 0xE0:
        I.mnem, I.ops = "MOV", f"{rw(lo)}, #{hi}"; return I
    if op == 0xE1:
        I.mnem, I.ops = "MOVB", f"{rb(lo)}, #{hi}"; return I
    if op == 0xE6:
        I.mnem, I.ops, I.regw = "MOV", f"{regw(b1)}, #0x{w:04X}", b1
        I.imm.append(w); return I
    if op == 0xE7:
        I.mnem, I.ops = "MOVB", f"{regb(b1)}, #0x{b[2]:02X}"; return I
    if op in (0xA8, 0xA9):
        I.mnem = "MOV" if op == 0xA8 else "MOVB"
        I.ops = f"{(rw if op == 0xA8 else rb)(hi)}, [{rw(lo)}]"; return I
    if op in (0x98, 0x99):
        I.mnem = "MOV" if op == 0x98 else "MOVB"
        I.ops = f"{(rw if op == 0x98 else rb)(hi)}, [{rw(lo)}+]"; return I
    if op in (0xB8, 0xB9):
        I.mnem = "MOV" if op == 0xB8 else "MOVB"
        I.ops = f"[{rw(lo)}], {(rw if op == 0xB8 else rb)(hi)}"; return I
    if op in (0x88, 0x89):
        I.mnem = "MOV" if op == 0x88 else "MOVB"
        I.ops = f"[-{rw(lo)}], {(rw if op == 0x88 else rb)(hi)}"; return I
    if op in (0xC8, 0xC9):
        I.mnem, I.ops = ("MOV" if op == 0xC8 else "MOVB"), f"[{rw(hi)}], [{rw(lo)}]"; return I
    if op in (0xD8, 0xD9):
        I.mnem, I.ops = ("MOV" if op == 0xD8 else "MOVB"), f"[{rw(hi)}+], [{rw(lo)}]"; return I
    if op in (0xE8, 0xE9):
        I.mnem, I.ops = ("MOV" if op == 0xE8 else "MOVB"), f"[{rw(hi)}], [{rw(lo)}+]"; return I
    if op in (0xD4, 0xF4):
        R = rw if op == 0xD4 else rb
        I.mnem, I.ops = ("MOV" if op == 0xD4 else "MOVB"), f"{R(hi)}, [{rw(lo)}+#0x{w:04X}]"
        I.imm.append(w); return I
    if op in (0xC4, 0xE4):
        R = rw if op == 0xC4 else rb
        I.mnem, I.ops = ("MOV" if op == 0xC4 else "MOVB"), f"[{rw(lo)}+#0x{w:04X}], {R(hi)}"
        I.imm.append(w); return I
    if op in (0x84, 0xA4):
        I.mnem, I.ops = ("MOV" if op == 0x84 else "MOVB"), f"[{rw(lo)}], {m16(w)}"
        I.mem.append((w, "r", op == 0xA4)); return I
    if op in (0x94, 0xB4):
        I.mnem, I.ops = ("MOV" if op == 0x94 else "MOVB"), f"{m16(w)}, [{rw(lo)}]"
        I.mem.append((w, "w", op == 0xB4)); return I
    if op in (0xF2, 0xF3):
        R = regw if op == 0xF2 else regb
        I.mnem, I.ops = ("MOV" if op == 0xF2 else "MOVB"), f"{R(b1)}, {m16(w)}"
        I.mem.append((w, "r", op == 0xF3)); return I
    if op in (0xF6, 0xF7):
        R = regw if op == 0xF6 else regb
        I.mnem, I.ops = ("MOV" if op == 0xF6 else "MOVB"), f"{m16(w)}, {R(b1)}"
        I.mem.append((w, "w", op == 0xF7)); return I
    if op in (0xC0, 0xD0):
        I.mnem, I.ops = ("MOVBZ" if op == 0xC0 else "MOVBS"), f"{rw(lo)}, {rb(hi)}"; return I
    if op in (0xC2, 0xD2):
        I.mnem, I.ops = ("MOVBZ" if op == 0xC2 else "MOVBS"), f"{regw(b1)}, {m16(w)}"
        I.mem.append((w, "r", 1)); return I
    if op in (0xC5, 0xD5):
        I.mnem, I.ops = ("MOVBZ" if op == 0xC5 else "MOVBS"), f"{m16(w)}, {regb(b1)}"
        I.mem.append((w, "w", 0)); return I
    # compare-and-increment/decrement
    cmpx = {0x80: "CMPI1", 0x90: "CMPI2", 0xA0: "CMPD1", 0xB0: "CMPD2"}
    if op in cmpx:
        I.mnem, I.ops = cmpx[op], f"{rw(lo)}, #{hi}"; return I
    if op - 6 in cmpx:
        I.mnem, I.ops = cmpx[op - 6], f"{rw(lo)}, #0x{w:04X}"; I.imm.append(w); return I
    if op - 2 in cmpx:
        I.mnem, I.ops = cmpx[op - 2], f"{rw(lo)}, {m16(w)}"; I.mem.append((w, "r", 0)); return I
    if op in (0x0B, 0x1B):
        I.mnem, I.ops = ("MUL" if op == 0x0B else "MULU"), f"{rw(hi)}, {rw(lo)}"; return I
    if op in (0x4B, 0x5B, 0x6B, 0x7B):
        I.mnem, I.ops = {0x4B: "DIV", 0x5B: "DIVU", 0x6B: "DIVL", 0x7B: "DIVLU"}[op], rw(hi); return I
    if op in (0x81, 0xA1, 0x91, 0xB1):
        I.mnem = {0x81: "NEG", 0xA1: "NEGB", 0x91: "CPL", 0xB1: "CPLB"}[op]
        I.ops = (rw if op in (0x81, 0x91) else rb)(hi); return I
    if op == 0x2B:
        I.mnem, I.ops = "PRIOR", f"{rw(hi)}, {rw(lo)}"; return I
    if op == 0xD1:
        n = ((b1 >> 4) & 3) + 1
        kind = "ATOMIC" if b1 >> 6 == 0 else ("EXTR" if b1 >> 6 == 2 else "D1?")
        I.mnem, I.ops = kind, f"#{n}"
        I.ext = ("r" if kind == "EXTR" else "a", None, n); return I
    if op == 0xDC:
        n = ((b1 >> 4) & 3) + 1
        kind = ["EXTS", "EXTP", "EXTSR", "EXTPR"][b1 >> 6]
        I.mnem, I.ops = kind, f"{rw(lo)}, #{n}"
        I.ext = (kind[3:].lower(), None, n); return I
    if op == 0xD7:
        n = ((b1 >> 4) & 3) + 1
        kind = ["EXTS", "EXTP", "EXTSR", "EXTPR"][b1 >> 6]
        if kind in ("EXTP", "EXTPR"):
            v = (b[3] & 0x3) << 8 | b[2]
            I.ops = f"#0x{v:03X}, #{n}"
        else:
            v = b[2]
            I.ops = f"#0x{v:02X}, #{n}"
        I.mnem = kind
        I.ext = (kind[3:].lower(), v, n); return I
    special = {0x87: "IDLE", 0x97: "PWRDN", 0xA7: "SRVWDT", 0xA5: "DISWDT", 0xB5: "EINIT", 0xB7: "SRST"}
    if op in special:
        I.mnem = special[op]
        if op == 0xB7:
            I.flow = "stop"
        return I
    I.mnem, I.ops, I.flow, I.bad = "DB", " ".join(f"0x{x:02X}" for x in b), "bad", True
    return I
