"""Memory model and paths for the DDE5.1 (EDC16C1, M67D39 / E65) analysis.

Images (built by build_bins.py from the SP-Daten exchange files):
  bin/7809330A_int_000000.bin   internal flash 0x000000-0x06FFFF (code from 0x10000; 0x0000-0x7FFF boot, not supplied)
  bin/7809330A_ext_800000.bin   external flash 0x800000-0x8FFFFF (program 0x820000-0x87FFFF; 0x800000-0x81FFFF not supplied)
  bin/V7810913_data.bin         calibration 0x8D0000-0x8FFFFF (data present from 0x8DFE00)
"""
import os
import struct

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.normpath(os.path.join(HERE, ".."))
REPO = os.path.normpath(os.path.join(ROOT, ".."))
BIN = os.path.join(ROOT, "bin")
OUT = os.path.join(ROOT, "out")
SGBD_DIR = os.path.join(ROOT, "sgbd")
SHARED = os.path.normpath(os.path.join(REPO, "..", "Shared"))   # C:\GIT-Private\BMW\Shared
SP = os.path.join(SHARED, "SP-Daten", "E65")
HEX_DIR = os.path.join(SP, "data", "DDE51")
PRG, DAT, SGBD = "7809330A.0pa", "V7810913.0da", "D51MM670"

CODE = [(0x010000, 0x070000), (0x8202E0, 0x830000), (0x840000, 0x880000)]
CAL = (0x8DFE00, 0x900000)
RAM = [(0x3F9800, 0x400000), (0x400000, 0x500000)]


class Mem:
    def __init__(self):
        self.regions = []
        for fn, base in (("7809330A_int_000000.bin", 0), ("V7810913_data.bin", 0x8D0000),
                         ("7809330A_ext_800000.bin", 0x800000)):
            self.regions.append((base, open(os.path.join(BIN, fn), "rb").read()))

    def find(self, a, n=1):
        for base, d in self.regions:
            if base <= a and a + n <= base + len(d):
                return d, a - base
        return None, None

    def u32(self, a):
        d, o = self.find(a, 4)
        return None if d is None else struct.unpack_from(">I", d, o)[0]

    def u16(self, a):
        d, o = self.find(a, 2)
        return None if d is None else struct.unpack_from(">H", d, o)[0]

    def s16(self, a):
        d, o = self.find(a, 2)
        return None if d is None else struct.unpack_from(">h", d, o)[0]

    def u8(self, a):
        d, o = self.find(a, 1)
        return None if d is None else d[o]

    def bytes(self, a, n):
        d, o = self.find(a, n)
        return None if d is None else d[o:o + n]


def is_code(a):
    return any(lo <= a < hi for lo, hi in CODE)


def is_cal(a):
    return CAL[0] <= a < CAL[1]


def is_ram(a):
    return any(lo <= a < hi for lo, hi in RAM)


ROM = [(0x008000, 0x070000), (0x820000, 0x880000)]


def is_rom(a):
    return any(lo <= a < hi for lo, hi in ROM)
