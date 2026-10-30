"""Convert BMW/Bosch Intel-HEX flash exchange files (.0PA / .0DA) to flat binaries.

Usage:
    python hex2bin.py <input.0PA|.0DA> <output.bin> [--base 0x80000] [--size 0x80000] [--fill 0xFF]
    python hex2bin.py --combine <out.bin> <file1> <file2> ...   (merge into one 0x80000..0xFFFFF image)

Header comment lines (';') and '$KEY value' lines are printed as metadata.
"""
import argparse
import sys


def parse_hex(path):
    mem = {}
    meta = {"comments": [], "dollar": []}
    seg = lin = 0
    with open(path, encoding="latin-1") as f:
        for lineno, line in enumerate(f, 1):
            line = line.strip()
            if not line:
                continue
            if line.startswith(";"):
                meta["comments"].append(line)
                continue
            if line.startswith("$"):
                meta["dollar"].append(line)
                continue
            if not line.startswith(":"):
                continue
            rec = bytes.fromhex(line[1:])
            n, addr, rtype = rec[0], (rec[1] << 8) | rec[2], rec[3]
            if (sum(rec) & 0xFF) != 0:
                raise ValueError(f"{path}:{lineno}: bad record checksum")
            data = rec[4:4 + n]
            # EDC16 files combine 02 (segment) and 04 (linear) records, and carry the last 16 bytes
            # of each 64 KB block in type 0x10 records
            if rtype in (0, 0x10):
                base = lin + seg + addr
                for i, b in enumerate(data):
                    mem[base + i] = b
            elif rtype == 2:
                seg = ((data[0] << 8) | data[1]) << 4
            elif rtype == 4:
                lin = ((data[0] << 8) | data[1]) << 16
            elif rtype == 1:
                break
    return mem, meta


def to_image(mems, base, size, fill):
    img = bytearray([fill]) * size
    for mem in mems:
        for a, v in mem.items():
            if base <= a < base + size:
                img[a - base] = v
    return img


def main(argv=None):
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("--combine", action="store_true", help="first positional is output, rest are inputs")
    p.add_argument("--base", type=lambda s: int(s, 0), default=None)
    p.add_argument("--size", type=lambda s: int(s, 0), default=None)
    p.add_argument("--fill", type=lambda s: int(s, 0), default=0xFF)
    p.add_argument("files", nargs="+")
    a = p.parse_args(argv)

    if a.combine:
        out, inputs = a.files[0], a.files[1:]
    else:
        if len(a.files) != 2:
            p.error("need <input> <output>")
        inputs, out = [a.files[0]], a.files[1]

    mems = []
    for path in inputs:
        mem, meta = parse_hex(path)
        mems.append(mem)
        print(f"{path}: {len(mem)} bytes, {min(mem):#07x}..{max(mem):#07x}", file=sys.stderr)
        for d in meta["dollar"]:
            print("   ", d, file=sys.stderr)

    lo = min(min(m) for m in mems)
    hi = max(max(m) for m in mems)
    base = a.base if a.base is not None else (0x80000 if a.combine else lo & ~0xFFFF)
    size = a.size if a.size is not None else (0x80000 if a.combine else ((hi - base) | 0xFFFF) + 1)
    img = to_image(mems, base, size, a.fill)
    with open(out, "wb") as f:
        f.write(img)
    print(f"wrote {out}: base {base:#07x}, size {size:#x}", file=sys.stderr)


if __name__ == "__main__":
    main()
