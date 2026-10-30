"""Disassemble the top flash sector (0xFC000-0xFFFFF) of a full DDE41A flash read.

The update files (.0PA/.0DA) don't cover this sector; it is only present in a full 512 KB read
of the external flash (e.g. bin/*.ori). Layout found in the O-release master:

  0xFC000, 0xFC300, 0xFC600  three 0x300-byte blocks, copied to RAM before use:
      header: A5A5, then 32-bit words: ptr1, ptr2, ptr3, end, info; run address = end - 0x300
              (the header sits at the run address; the pointers are entry points/data inside the block)
      trailer at +0x2FA: 97 C1 + 4-byte checksum
  0xFCC00-0xFEBF9            code that runs in place (segment 0x0F), trailer 97 C1 at 0xFEBFA
  0xFEC00..                  ID area (Bosch number, "B101EWS000", references)

Usage: python topsector.py [full_read.bin|.ori]   -> <variant>/out/topsector.asm, topsector.md
"""
import glob
import os
import struct
import sys
from collections import defaultdict

import variant as V
from c166 import decode

BASE = 0x80000
BOOT_NAMES = {0x0CB2: "rom_KL_interp", 0x0CDC: "rom_KF_interp", 0x2000: "rom_fault_report",
              0x0830: "rom_task_prologue", 0x02D6: "rom_fatal_reset"}


def w16(d, off):
    return struct.unpack_from("<H", d, off)[0]


def find_blocks(d):
    """Return list of (name, file_offset, size, run_address, entries)."""
    blocks = []
    for off in range(0xFC000 - BASE, 0xFCC00 - BASE, 0x300):
        if d[off:off + 2] != b"\xa5\xa5":
            continue
        dw = [w16(d, off + 2 + 4 * k) | w16(d, off + 4 + 4 * k) << 16 for k in range(5)]
        end = dw[3]
        base = end - 0x300          # the header itself sits at the run address
        size = 0x300
        entries = [x for x in dw[1:3] if base + 0x14 <= x < end]   # ptr1 = data/config, ptr2/ptr3 = code
        blocks.append(dict(name=f"ram_block_{base:04X}", file=off + BASE, size=size, run=base,
                           entries=entries, header=dw))
    # in-place block: from 0xFCC00 to the 97 C1 trailer before the ID area
    lo = 0xFCC00 - BASE
    hi = d.find(b"\x97\xc1", lo)
    if hi > 0:
        blocks.append(dict(name="flash_block_FCC00", file=lo + BASE, size=hi - lo, run=lo + BASE,
                           entries=[lo + BASE], header=None))
    return blocks


def explore(img, base, size, entries):
    """Recursive descent inside one block; img is the block bytes, base its run address."""
    insns, labels, calls_out = {}, set(), defaultdict(set)
    work = list(entries)
    seen = set()
    while work:
        a = work.pop()
        if a in seen or not (base <= a < base + size):
            continue
        seen.add(a)
        while base <= a < base + size and a not in insns:
            i = decode(img, a - base, a)
            insns[a] = i
            if i.bad:
                break
            t = i.target
            if t is not None:
                if base <= t < base + size:
                    labels.add(t)
                    work.append(t)
                else:
                    calls_out[t].add(a)
            if i.flow in ("jmp", "ret", "ijmp", "stop"):
                break
            a += i.size
    return insns, labels, calls_out


def sweep_starts(img, base, size, insns):
    """Additional starts: code after returns that wasn't reached (handlers called via tables/ROM)."""
    starts = []
    a = base
    while a < base + size:
        if img[a - base:a - base + 2] in (b"\xc3\xc3", b"\xff\xff"):
            a += 2
            continue
        i = decode(img, a - base, a)
        if i.bad:
            a += 2
            continue
        nxt = a + i.size
        if i.flow == "ret" and nxt not in insns and nxt < base + size and img[nxt - base:nxt - base + 2] not in (b"\xc3\xc3", b"\xff\xff"):
            starts.append(nxt)
        a = nxt
    return starts


def main():
    path = sys.argv[1] if len(sys.argv) > 1 else (glob.glob(os.path.join(V.BIN, "*.ori")) or [None])[0]
    if not path:
        raise SystemExit("no full flash read (*.ori) found in " + V.BIN)
    d = open(path, "rb").read()
    if len(d) != 0x80000:
        raise SystemExit("expected a 512 KB read of 0x80000-0xFFFFF")
    os.makedirs(V.OUT, exist_ok=True)
    blocks = find_blocks(d)
    asm = open(os.path.join(V.OUT, "topsector.asm"), "w", encoding="utf-8")
    asm.write(f"; Top flash sector 0xFC000-0xFFFFF from {os.path.basename(path)}\n")
    asm.write("; RAM blocks are listed at their run address; 'flash' = address in the 0x80000 flash image\n\n")
    summary = []
    for b in blocks:
        off = b["file"] - BASE
        img = d[off:off + b["size"]]
        insns, labels, calls_out = explore(img, b["run"], b["size"], b["entries"])
        for _ in range(3):
            extra = sweep_starts(img, b["run"], b["size"], insns)
            if not extra:
                break
            labels.update(extra)
            i2, l2, c2 = explore(img, b["run"], b["size"], extra)
            insns.update(i2)
            labels |= l2
            for k, v in c2.items():
                calls_out[k] |= v
        code = sum(i.size for i in insns.values())
        rom = sorted(t for t in calls_out if t < 0x10000)
        asm.write(f";{'=' * 74}\n; {b['name']}: flash {b['file']:06X}-{b['file'] + b['size'] - 1:06X}, "
                  f"runs at {b['run']:06X}, {b['size']} bytes, {code} bytes decoded\n")
        if b["header"]:
            asm.write("; header (32-bit words): ptr1 {:06X} ptr2 {:06X} ptr3 {:06X} end {:06X} info {:08X}\n".format(*b["header"]))
        asm.write(f";{'=' * 74}\n")
        prev = None
        for a in sorted(insns):
            i = insns[a]
            if prev is not None and a != prev:
                asm.write("\n")
            if a in b["entries"]:
                asm.write(f"entry_{a:06X}:\n")
            elif a in labels:
                asm.write(f"loc_{a:06X}:\n")
            txt = i.text()
            if i.target is not None and i.target < 0x10000 and i.mnem in ("CALLS", "JMPS"):
                txt += f"    ; -> {BOOT_NAMES.get(i.target, f'rom_{i.target:04X}')}"
            asm.write(f"  {a:06X}: {i.raw.hex():<8}  {txt}\n")
            prev = a + i.size
        asm.write("\n")
        summary.append((b, code, rom, len(insns)))
    asm.close()

    id_off = 0xFEBFA - BASE
    ident = d[id_off:id_off + 0x60]
    with open(os.path.join(V.OUT, "topsector.md"), "w", encoding="utf-8") as f:
        f.write(f"# Top flash sector (0xFC000-0xFFFFF) of {V.NAME}\n\nGenerated by `tools/topsector.py` from "
                f"`{os.path.basename(path)}`. Disassembly: [`topsector.asm`](topsector.asm).\n\n")
        f.write("| Block | Flash | Runs at | Size | Decoded | Instructions | ROM calls |\n|---|---|---|---|---|---|---|\n")
        for b, code, rom, n in summary:
            f.write(f"| `{b['name']}` | {b['file']:06X} | {b['run']:06X} | {b['size']} | {code} | {n} | "
                    + (", ".join(f"0:{t:04X}" for t in rom[:12]) + (" …" if len(rom) > 12 else "")) + " |\n")
        f.write("\nID area at 0xFEBFA (printable bytes): `" + "".join(chr(c) if 32 <= c < 127 else "." for c in ident) + "`\n")
    for b, code, rom, n in summary:
        print(f"{b['name']:<20} flash {b['file']:06X} run {b['run']:06X} size {b['size']:5d} decoded {code:5d} insns {n:5d} rom calls {len(rom)}")


if __name__ == "__main__":
    main()
