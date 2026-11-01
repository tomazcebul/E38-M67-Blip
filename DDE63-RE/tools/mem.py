"""Memory model and paths for the DDE6.3 (EDC16CP35, M67TUE / E65) analysis.

Image: bin/full_<PRG>_<DAT>.bin = program + data, flat 0x000000-0x47FFFF (built by build_bins.py).

Program blocks (linked headers 0x100000 -> 0x404000 -> 0x0C0000, range list at 0x0103D0):
  0x010000-0x03FFBF  startup, vector table (reset -> 0x01E138), operating system; code to 0x027BCF
  0x03C440-0x053A00  constant tables (r2 = 0x0480F0, r14 = 0x04653C)
  0x053A00-0x099FFF  code
  0x100000-0x13FFFF  code
  0x404000-0x47FFFF  code
Data (.0da): 0x0C0000-0x0FCFFF calibration.
RAM: 0x6F8000-0x707FFF, 0x7F0000-0x80FFFF (r13 = 0x7FFFF0, stack top 0x800000), 0x8FD000-0x8FFFFF.
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
HEX_DIR = os.path.join(SP, "data", "DDE63")
PRG, DAT, SGBD = "7808738A.0pa", "T7808736.0da", "D63MM670"
FULL = os.path.join(BIN, f"full_{PRG[:-4]}_{DAT[:-4]}.bin")

CODE = [(0x010000, 0x027BD0), (0x053A00, 0x09A000), (0x100000, 0x13E9B0), (0x404058, 0x47F9B0)]
CAL = (0x0C0000, 0x0FD000)
RAM = [(0x6F8000, 0x708000), (0x7F0000, 0x810000), (0x8FD000, 0x900000)]
ROM = [(0x03C440, 0x053A00)]


class Mem:
    def __init__(self):
        self.d = open(FULL, "rb").read()
        self.regions = [(0, self.d)]

    def find(self, a, n=1):
        return (self.d, a) if 0 <= a and a + n <= len(self.d) else (None, None)

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


def is_rom(a):
    return any(lo <= a < hi for lo, hi in ROM)
