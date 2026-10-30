"""Variant selection and layout detection shared by all tools.

Select the ECU with the environment variable DDE_VARIANT (A = master DDE41A, B = slave DDE41B),
or with `python run_all.py --variant B`. Outputs go to <repo>/DDE41A-RE or <repo>/DDE41B-RE.
"""
import os
import struct

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.normpath(os.path.join(HERE, "..", ".."))
SP = os.path.join(REPO, "BMW-SPdaten-v.60.1", "E38")
BASE = 0x80000

VARIANTS = {
    "A": dict(name="DDE41A", role="Master", prg="7787316O.0PA", dat="Y7787646.0DA", sgbd="DDE41KR0"),
    "B": dict(name="DDE41B", role="Slave", prg="7787317O.0PA", dat="Y7787648.0DA", sgbd="DDE41KL0"),
}

KEY = os.environ.get("DDE_VARIANT", "A").upper()
V = VARIANTS[KEY]
NAME = V["name"]
ROOT = os.path.join(REPO, f"{NAME}-RE")
OUT = os.path.join(ROOT, "out")
BIN = os.path.join(ROOT, "bin")
SGBD_DIR = os.path.join(ROOT, "sgbd")
IMAGE = os.path.join(BIN, f"{NAME}_O_full_80000.bin")
HEX_DIR = os.path.join(SP, "data", NAME)
PRG = os.path.join(HEX_DIR, V["prg"])
DAT = os.path.join(HEX_DIR, V["dat"])
SGBD_PRG = os.path.join(SP, "ecu", V["sgbd"] + ".prg")
BETRIEBSWTAB = os.path.join(SGBD_DIR, V["sgbd"] + "_BETRIEBSWTAB.csv")


def w16(img, a):
    return struct.unpack_from("<H", img, a - BASE)[0]


def cal_ptr(v):
    """16-bit DPP0/DPP1 pointer -> physical calibration address."""
    return (0xF0000 if v < 0x4000 else 0xF4000) + (v & 0x3FFF)


def label_table(img, lo=0xF1000):
    """Label pointer table: consecutive DPP0/DPP1 pointers from 0xF1000 up to the first label."""
    hi, first = lo, 0xFC000
    while hi < first:
        v = w16(img, hi)
        if v >= 0x8000 or not (lo <= cal_ptr(v) < 0xFC000):
            break
        first = min(first, cal_ptr(v))
        hi += 2
    return lo, hi


def data_end(img):
    """First address after the last label where erased flash (0xC3 run of >= 64 bytes) starts."""
    lo, hi = label_table(img)
    last = max(cal_ptr(w16(img, a)) for a in range(lo, hi, 2))
    a = last
    while a < 0xFC000:
        if img[a - BASE:a - BASE + 64] == b"\xc3" * 64:
            return a
        a += 2
    return 0xFC000


def measurement_table(img, wanted_ids=()):
    """Find '55 AA', count, <count> sorted IDs, <count> RAM addresses. Returns (addr, ids, addrs)."""
    best = None
    wanted = set(wanted_ids)
    for o in range(0x10000, 0x40000, 2):
        if img[o:o + 2] not in (b"\x55\xaa", b"\xaa\x55"):
            continue
        a = BASE + o
        n = w16(img, a + 2)
        if not 8 <= n <= 1000:
            continue
        ids = [w16(img, a + 4 + 2 * k) for k in range(n)]
        if ids != sorted(ids) or len(set(ids)) != n:
            continue
        addrs = [w16(img, a + 4 + 2 * n + 2 * k) for k in range(n)]
        score = (len(wanted.intersection(ids)), n)
        if best is None or score > best[0]:
            best = (score, a, ids, addrs)
    if best is None:
        raise SystemExit("measurement table not found")
    return best[1], best[2], best[3]
