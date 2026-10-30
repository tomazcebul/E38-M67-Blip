"""Decode an EDIABAS SGBD (.prg): info block, job list and tables.

EDIABAS objects are XOR-obfuscated with 0xF7. Offsets (little-endian, read from the raw file):
  0x84 -> table directory   (count, then 0x50-byte entries: name[0x40], offset, ?, columns)
  0x88 -> job directory     (count, then 0x44-byte entries: name[0x40], offset)
  0x90 -> info text block

Usage: python sgbd.py <file.prg> [outdir]   -> <name>_jobs.txt, <name>_<TABLE>.csv
"""
import csv
import os
import struct
import sys


def read(path):
    raw = open(path, "rb").read()
    return raw, bytes(b ^ 0xF7 for b in raw)


def info(raw, d):
    o = struct.unpack_from("<I", raw, 0x90)[0]
    return d[o:o + 2000].split(b"\0")[0].decode("latin-1")


def jobs(raw, d):
    o = struct.unpack_from("<I", raw, 0x88)[0] + 4
    out = []
    while len(out) < 2000:
        nm = d[o:o + 0x40].split(b"\0")[0]
        if not nm or not nm[:1].isalpha():
            break
        out.append(nm.decode("latin-1"))
        o += 0x44
    return out


def tables(raw, d):
    toff = struct.unpack_from("<I", raw, 0x84)[0]
    n = struct.unpack_from("<I", d, toff)[0]
    p = toff + 4
    tabs = []
    for _ in range(n):
        name = d[p:p + 0x40].split(b"\0")[0].decode("latin-1")
        off, _x, cols = struct.unpack_from("<III", d, p + 0x40)
        tabs.append((name, off, cols))
        p += 0x50
    offs = sorted(t[1] for t in tabs) + [toff]
    result = {}
    for name, off, cols in tabs:
        end = min(x for x in offs if x > off)
        cells = [s.decode("latin-1") for s in d[off:end].split(b"\0")]
        rows = [cells[i:i + cols] for i in range(0, len(cells) - cols + 1, cols)]
        result[name] = rows
    return result


def main():
    path = sys.argv[1]
    outdir = sys.argv[2] if len(sys.argv) > 2 else "."
    os.makedirs(outdir, exist_ok=True)
    raw, d = read(path)
    base = os.path.splitext(os.path.basename(path))[0]
    js = jobs(raw, d)
    with open(os.path.join(outdir, f"{base}_jobs.txt"), "w", encoding="utf-8") as f:
        f.write(info(raw, d).split("JOBNAME")[0].strip() + "\n\n")
        f.write("\n".join(js) + "\n")
    for name, rows in tables(raw, d).items():
        with open(os.path.join(outdir, f"{base}_{name}.csv"), "w", newline="", encoding="utf-8") as f:
            csv.writer(f).writerows(rows)
        print(f"{name}: {len(rows) - 1} rows")
    print(f"{len(js)} jobs")


if __name__ == "__main__":
    main()
