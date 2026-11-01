"""Run the ORIGINAL SGBD status jobs in the EdiabasLib simulator and measure the telegram layout and scaling.

For every job (default: all STATUS_* jobs of the variant's SGBD):
    1. the job runs without simulation data; the IFH trace shows the KWP2000 request ("(Send sim): B8 12 F1 ...");
    2. a positive response `B8 F1 <ecu> <len> <SID+0x40> <first parameter byte> <data...> <XOR>` is added
       (repeated for jobs that send several requests);
    3. every data byte is set to 0x01, and to 0x80 for the most significant byte of a field; the change of each
       numeric result gives bytes, byte order, factor, offset and sign. Results that don't react are swept bit by bit.
The measurement ID of `2C 10 <ID hi> <ID lo>` (dynamically defined local identifier) is joined with the firmware
measurement table (out/measurement_table.csv) to give the RAM variable each job reads.

Requires EdiabasTest.exe from EdiabasLib (in ../../../Shared/EdiabasLib, see ../../../GSB233-8HP/README.md).

Usage:  python ediabas_probe.py [--exe=<EdiabasTest.exe>] [--jobs=JOB1,JOB2 [--merge=1]]   (variant via DDE_VARIANT / run_all)
        --merge=1 re-measures only the given jobs and keeps the other rows of out/ediabas_status.csv
Writes: out/ediabas_status.csv, out/ediabas_status.md
"""
import csv
import os
import re
import shutil
import subprocess
import sys
import tempfile

import sgbd
import variant as V

EXE = os.path.join(V.SHARED, "EdiabasLib", "ediabaslib", "EdiabasLib", "EdiabasTest", "bin", "Release",
                   "net481", "EdiabasTest.exe")
NDATA = 8


def ndata(req):
    """Data bytes to answer with: 2 per measurement ID of a 2C request (at least NDATA)."""
    b = req.split(",")
    return max(NDATA, 2 * ((len(b) - 6) // 2) + 2) if len(b) > 4 and b[4] == "2C" else NDATA


def xor_tel(b):
    x = 0
    for v in b:
        x ^= v
    return ",".join(f"{v:02X}" for v in b + bytes([x]))


class Sim:
    def __init__(self, exe, prg):
        self.exe, self.work = exe, tempfile.mkdtemp(prefix="ddesim_")
        self.name = os.path.splitext(os.path.basename(prg))[0].lower()
        shutil.copy(prg, os.path.join(self.work, self.name + ".prg"))

    def response(self, req, data):
        """Positive KWP2000 response to a request 'B8,12,F1,len,SID,p1,...' with the given data bytes."""
        b = [int(x, 16) for x in req.split(",")]
        ecu, sid = b[1], b[4]
        echo = bytes(b[5:6]) if sid in (0x21, 0x22, 0x2C, 0x30, 0x31, 0x1A, 0x17) and len(b) > 5 else b""
        payload = bytes([sid + 0x40]) + echo + data
        return xor_tel(bytes([0xB8, 0xF1, ecu, len(payload)]) + payload)

    def run(self, job, pairs):
        with open(os.path.join(self.work, self.name + ".sim"), "w") as fh:
            fh.write("[REQUEST]\n" + "".join(f"key{i}={r}\n" for i, (r, _) in enumerate(pairs)) +
                     "[RESPONSE]\n" + "".join(f"key{i}={s}\n" for i, (_, s) in enumerate(pairs)))
        trc = os.path.join(self.work, "ifh.trc")
        if os.path.exists(trc):
            os.remove(trc)
        out = subprocess.run([self.exe, "--ifh=STD:OBD", "-p", "COM9",
                              f"--cfg=Simulation=1;SimulationPath={self.work};EcuPath={self.work};IfhTrace=3;"
                              f"TracePath={self.work}", "-s", os.path.join(self.work, self.name + ".prg"), "-j", job],
                             capture_output=True, text=True, encoding="utf-8", errors="replace", timeout=120).stdout
        sent = []
        if os.path.exists(trc):
            for ln in open(trc, encoding="utf-8", errors="replace"):
                m = re.search(r"\(Send sim\): ([0-9A-F ]+)", ln)
                if m:
                    sent.append(m.group(1).strip().replace(" ", ","))
        res, in_data = {}, False
        for ln in out.splitlines():
            if ln.startswith("DATASET: 1"):
                in_data = True
                continue
            m = re.match(r"^(\w+):\s*(?:([A-Z]{1,2}):\s*)?(.*)$", ln)
            if in_data and m:
                name, typ, val = m.groups()
                try:
                    res[name] = float(val.split()[0]) if typ == "R" else int(val.split()[0]) if typ else val.strip()
                except (ValueError, IndexError):
                    res[name] = val.strip()
        return res, sent

    def cleanup(self):
        shutil.rmtree(self.work, ignore_errors=True)


def probe(sim, job):
    reqs = []
    for _ in range(6):
        res, sent = sim.run(job, [(r, sim.response(r, bytes(ndata(r)))) for r in reqs])
        new = [s for s in sent if s not in reqs]
        if not new:
            break
        reqs.append(new[0])
    base, _ = sim.run(job, [(r, sim.response(r, bytes(ndata(r)))) for r in reqs])
    if base.get("JOB_STATUS") != "OKAY":
        return {"job": job, "requests": reqs, "status": str(base.get("JOB_STATUS", "no result")), "fields": {}, "texts": {}}
    nums = {k: v for k, v in base.items() if isinstance(v, (int, float)) and k != "SAETZE"}
    texts = {k: v for k, v in base.items() if isinstance(v, str) and k != "JOB_STATUS"}

    def answer(ri, pl):
        return [(q, sim.response(q, pl if i == ri else bytes(ndata(q)))) for i, q in enumerate(reqs)]

    fields = {}
    for ri in range(len(reqs)):
        n = ndata(reqs[ri])
        deltas = {k: {} for k in nums if not k.endswith("_EIN")}
        for b in range(n):
            pl = bytearray(n)
            pl[b] = 1
            r, _ = sim.run(job, answer(ri, bytes(pl)))
            for k in deltas:
                if isinstance(r.get(k), (int, float)) and r[k] != nums[k]:
                    deltas[k][b] = r[k] - nums[k]
        for k, dl in deltas.items():
            if not dl or k in fields:
                continue
            bs = sorted(dl)
            lsb = min(bs, key=lambda x: abs(dl[x]))
            order = "big" if lsb == bs[-1] else "little" if lsb == bs[0] else "?"
            msb = bs[0] if order == "big" else bs[-1]
            pl = bytearray(n)
            pl[msb] = 0x80
            r, _ = sim.run(job, answer(ri, bytes(pl)))
            expect = nums[k] + dl[lsb] * 0x80 * (256 ** (len(bs) - 1))
            signed = isinstance(r.get(k), (int, float)) and abs(r[k] - expect) > 1e-6 * max(1, abs(expect))
            fields[k] = {"request": ri, "bytes": bs, "order": order, "factor": dl[lsb], "offset": nums[k],
                         "signed": signed}
    flags = [k for k in nums if k not in fields]
    if flags:   # bit flags (and anything that didn't react to 0x01): sweep every bit of every data byte
        for ri in range(len(reqs)):
            n = ndata(reqs[ri])
            for b in range(n):
                for bit in range(8):
                    pl = bytearray(n)
                    pl[b] = 1 << bit
                    r, _ = sim.run(job, answer(ri, bytes(pl)))
                    for k in flags:
                        if k not in fields and isinstance(r.get(k), (int, float)) and r[k] != nums[k]:
                            fields[k] = {"request": ri, "bytes": [b], "bit": bit, "order": "bit",
                                         "factor": r[k] - nums[k], "offset": nums[k], "signed": False}
    for k in nums:
        fields.setdefault(k, {"const": nums[k]})
    return {"job": job, "requests": reqs, "status": "OKAY", "fields": fields, "texts": texts}


def main():
    opt = dict(a[2:].split("=", 1) for a in sys.argv[1:] if a.startswith("--") and "=" in a)
    raw, d = sgbd.read(V.SGBD_PRG)
    jobs = opt["jobs"].split(",") if "jobs" in opt else [j for j in sgbd.jobs(raw, d) if j.startswith("STATUS_")]
    meas = {}   # {diagnostic address: {measurement id: row}}; 0x12 = master DDE41A, 0x13 = slave DDE41B
    for addr, name in ((0x12, "DDE41A"), (0x13, "DDE41B")):
        mt = os.path.join(V.REPO, f"{name}-RE", "out", "measurement_table.csv")
        if os.path.exists(mt):
            meas[addr] = {int(r["id"], 16): r for r in csv.DictReader(open(mt, encoding="utf-8"))}
    btab = {}
    for path in (V.BETRIEBSWTAB, V.BETRIEBSWTAB.replace("BETRIEBSWTAB", "BETRIEBSWTABSL")):
        if os.path.exists(path):
            for r in csv.DictReader(open(path, encoding="utf-8")):
                btab.setdefault(r["JOBNAME"].upper(), r)
    sim = Sim(opt.get("exe", EXE), V.SGBD_PRG)
    rows = []
    merged = opt.get("merge") == "1" and "jobs" in opt   # re-measure only some jobs, keep the others
    old = []
    out_csv = os.path.join(V.OUT, "ediabas_status.csv")
    if merged and os.path.exists(out_csv):
        old = list(csv.DictReader(open(out_csv, encoding="utf-8")))
    try:
        for i, job in enumerate(jobs):
            p = probe(sim, job)
            print(f"[{i + 1}/{len(jobs)}] {job}: {p['status']} {len(p['requests'])} request(s)", flush=True)
            ids, ram = [], []
            for q in p["requests"]:
                b = [int(x, 16) for x in q.split(",")]
                if len(b) >= 8 and b[4] == 0x2C:
                    tab = meas.get(b[1], {})
                    for k in range(6, len(b) - 1, 2):
                        i = b[k] << 8 | b[k + 1]
                        ids.append(i)
                        if i in tab:
                            ram.append(f"0x{i:04X}->{tab[i]['ram_address']}" + (" (slave)" if b[1] == 0x13 and V.KEY == "A" else ""))
            ram = "; ".join(ram)
            bt = btab.get(job.replace("STATUS_", "").upper(), {})
            unit = next((v for k, v in p["texts"].items() if k.endswith("_EINH")), "")
            base = {"job": job, "status": p["status"], "requests": " | ".join(q.replace(",", " ") for q in p["requests"]),
                    "meas_ids": " ".join(f"0x{i:04X}" for i in ids), "ram": ram, "unit": unit,
                    "sgbd_fact_a": bt.get("FACT_A", ""), "sgbd_fact_b": bt.get("FACT_B", "")}
            if not p["fields"]:
                rows.append(dict(base, result="", bytes="", order="", signed="", factor="", offset=""))
            for k, f in p["fields"].items():
                if "const" in f:
                    rows.append(dict(base, result=k, bytes="", order="const", signed="", factor="", offset=f["const"]))
                    continue
                pos = ",".join(str(6 + b) for b in f["bytes"])      # index in the full telegram (B8 F1 ecu len SID p1 data)
                if "bit" in f:
                    pos += f".{f['bit']}"
                rows.append(dict(base, result=k, bytes=(f"req{f['request'] + 1}:" if len(p['requests']) > 1 else "") + pos,
                                 order=f["order"], signed="yes" if f["signed"] else "", factor=f"{f['factor']:.8g}",
                                 offset=f"{f['offset']:.8g}"))
    finally:
        sim.cleanup()
    if old:
        redone = {r["job"] for r in rows}
        new_by_job = {}
        for r in rows:
            new_by_job.setdefault(r["job"], []).append(r)
        combined, done = [], set()
        for r in old:
            if r["job"] in redone:
                if r["job"] not in done:
                    combined += new_by_job[r["job"]]
                    done.add(r["job"])
            else:
                combined.append(r)
        rows = combined + [r for j, rs in new_by_job.items() if j not in done for r in rs]
    with open(os.path.join(V.OUT, "ediabas_status.csv"), "w", newline="", encoding="utf-8") as fh:
        w = csv.DictWriter(fh, fieldnames=list(rows[0]))
        w.writeheader()
        w.writerows(rows)
    ok = sum(1 for r in {r["job"]: r for r in rows}.values() if r["status"] == "OKAY")
    md = [f"# {V.NAME} – status jobs of `{V.V['sgbd']}.prg` measured in the EdiabasLib simulator", "",
          "Generated by `tools/ediabas_probe.py`: the original SGBD job code runs against simulated ECU answers "
          "(KWP2000 on K-line, `B8 <ecu> F1 <len> <SID> …`, XOR checksum). **Byte** = index in the full response "
          "`B8 F1 <ecu> <len> <SID+0x40> <param> <data…>` (data starts at byte 6). Physical value = raw × factor + "
          "offset. **Meas. ID → RAM** joins the ID requested with `2C 10 <ID>` to the firmware measurement table. "
          f"{ok} of {len({r['job'] for r in rows})} jobs ran to `OKAY`.", "",
          "| Job | Request(s) | Meas. ID → RAM | Result | Byte(s) | Order | Signed | Factor | Offset | Unit | SGBD FACT_A / FACT_B |",
          "|---|---|---|---|---|---|---|---|---|---|---|"]
    last = None
    for r in rows:
        first = r["job"] != last
        last = r["job"]
        md.append(("| `" + r["job"] + "` | `" + r["requests"] + "` | " + r["ram"] + " " if first else "| | | ") +
                  f"| {r['result'] or r['status']} | {r['bytes']} | {r['order']} | {r['signed']} | {r['factor']} | "
                  f"{r['offset']} | {r['unit'] if first else ''} | "
                  f"{(r['sgbd_fact_a'] + ' / ' + r['sgbd_fact_b']) if first and r['sgbd_fact_a'] else ''} |")
    with open(os.path.join(V.OUT, "ediabas_status.md"), "w", encoding="utf-8", newline="\n") as fh:
        fh.write("\n".join(md) + "\n")
    print(f"ediabas_status: {len(rows)} rows, {ok} jobs OKAY")


if __name__ == "__main__":
    main()
