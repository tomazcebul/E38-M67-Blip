"""Regenerate every artifact for one ECU variant from the SP-Daten source files.

Usage: python run_all.py [--variant A|B]     (A = master DDE41A, B = slave DDE41B; default A)
Outputs: <repo>/DDE41A-RE or <repo>/DDE41B-RE  (bin/, sgbd/, out/)
"""
import argparse
import os
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))


def main():
    p = argparse.ArgumentParser()
    p.add_argument("--variant", default=os.environ.get("DDE_VARIANT", "A"), choices=["A", "B", "a", "b"])
    a = p.parse_args()
    env = dict(os.environ, DDE_VARIANT=a.variant.upper())
    os.environ.update(env)
    import variant as V

    def run(*args):
        print(">", " ".join(os.path.basename(x) if os.sep in x else x for x in args))
        subprocess.run([sys.executable, *args], check=True, cwd=HERE, env=env)

    os.makedirs(V.BIN, exist_ok=True)
    stem_p, stem_d = os.path.splitext(V.V["prg"])[0], os.path.splitext(V.V["dat"])[0]
    run("hex2bin.py", V.PRG, os.path.join(V.BIN, f"{stem_p}_program.bin"), "--base", "0x80000", "--size", "0x70000")
    run("hex2bin.py", V.DAT, os.path.join(V.BIN, f"{stem_d}_data.bin"), "--base", "0xF0000", "--size", "0x10000")
    run("hex2bin.py", "--combine", V.IMAGE, V.PRG, V.DAT)
    run("sgbd.py", V.SGBD_PRG, V.SGBD_DIR)
    run("meastab.py")
    run("analyze.py")
    run("maps.py")
    run("params.py")
    run("analyze.py")  # second pass: annotate the listing with map/curve labels from maps.json
    import glob
    if glob.glob(os.path.join(V.BIN, "*.ori")):
        run("topsector.py")  # only with a full 512 KB flash read (not part of the SP-Daten files)


if __name__ == "__main__":
    main()
