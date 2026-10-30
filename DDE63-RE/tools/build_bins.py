"""Build flat images of the DDE6.3 (EDC16CP35, M67TUE) exchange files from SP-Daten E65/data/DDE63.

Writes bin/<file>.bin (0x000000-0x47FFFF, unused bytes 0xFF) for every program (.0pa) and data (.0da)
file, and bin/full_<program>_<data>.bin with program and data combined (the data lies inside the
program address space at 0x0C0000-0x0FCFFF).

Usage: python build_bins.py
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "..", "DDE41A-RE", "tools"))
import hex2bin  # noqa: E402

import mem as M  # noqa: E402

SIZE = 0x480000


def main():
    os.makedirs(M.BIN, exist_ok=True)
    mems = {}
    for f in sorted(os.listdir(M.HEX_DIR)):
        if f.lower().endswith((".0pa", ".0da")):
            mem, meta = hex2bin.parse_hex(os.path.join(M.HEX_DIR, f))
            mems[f] = mem
            img = hex2bin.to_image([mem], 0, SIZE, 0xFF)
            open(os.path.join(M.BIN, f.replace(".", "_") + ".bin"), "wb").write(img)
            print(f"{f}: {len(mem)} bytes, {min(mem):#08x}..{max(mem):#08x}", " ".join(meta["dollar"][:1]))
    img = hex2bin.to_image([mems[M.PRG], mems[M.DAT]], 0, SIZE, 0xFF)
    open(M.FULL, "wb").write(img)
    print("wrote", M.FULL)


if __name__ == "__main__":
    main()
