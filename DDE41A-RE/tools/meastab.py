"""Extract the measurement-ID table from the DDE41x program and join it with the SGBD.

Firmware layout: "55 AA" marker (either byte order), count, <count> sorted 16-bit measurement IDs,
then <count> 16-bit RAM addresses in the same order. The table is located automatically
(DDE41A O: 0x091000, 260 entries; DDE41B O: 0x090800, 175 entries). The diagnostic SGBD
BETRIEBSWTAB (DDE41KR0 / DDE41KL0) uses the same IDs in its ADR column.

Usage: python meastab.py  -> <variant>/out/measurement_table.csv
"""
import csv
import os

import variant as V


def main():
    img = open(V.IMAGE, "rb").read()
    sg = {}
    for r in list(csv.reader(open(V.BETRIEBSWTAB, encoding="utf-8")))[1:]:
        if len(r) > 16 and r[4].startswith("0x"):
            sg.setdefault(int(r[4], 16), r)
    at, ids, addrs = V.measurement_table(img, sg)
    os.makedirs(V.OUT, exist_ok=True)
    hit = 0
    with open(os.path.join(V.OUT, "measurement_table.csv"), "w", newline="", encoding="utf-8") as f:
        wr = csv.writer(f)
        wr.writerow(["id", "ram_address", "sgbd_name", "unit", "factor", "offset", "description"])
        for i, a in zip(ids, addrs):
            r = sg.get(i)
            hit += bool(r)
            wr.writerow([f"0x{i:04X}", f"0x{a:04X}"] + ([r[0], r[13], r[8], r[9], r[16]] if r else [""] * 5))
    print(f"table at 0x{at:06X}: {len(ids)} IDs, {hit} named via SGBD ({len(sg)} SGBD IDs)")


if __name__ == "__main__":
    main()
