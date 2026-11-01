# DDE6.3 (EDC16CP35, M67TUE / M67D44, E65 745d): reverse engineering

Static analysis of the E65 745d M67TUE DDE6.3 software from SP-Daten v60.1 (`E65\data\DDE63`), focused on the gearbox torque interface (`TORQUE_GEARBX` 0x0B5). Summary and release data: [M67-DDE63-Findings.md](../M67-DDE63-Findings.md).

| | |
|---|---|
| Program | [`7808738A.0pa`](../../Shared/SP-Daten/E65/data/DDE63/7808738A.0pa): EDC16CP35, project "M67TUE/E65", reference `0089R10A9G3B`, Bosch hardware 0 281 012 479 |
| Data | [`T7808736.0da`](../../Shared/SP-Daten/E65/data/DDE63/T7808736.0da) (220 kW, `...G3BEZ220`); `T7808737.0da` is the 242 kW variant (240 bytes differ) |
| Diagnostic SGBD | [`D63MM670.prg`](../../Shared/SP-Daten/E65/ecu/D63MM670.prg) (master), `D63SM670.prg` (slave) |
| CPU | Freescale MPC5xx (PowerPC, big-endian) |

## Memory map

The exchange files contain everything except the boot block 0x000000-0x00FFFF. Unlike the DDE5.1 (460 calls into missing flash) only 5 calls go to addresses outside the supplied code.

| Address | Content |
|---|---|
| 0x000000-0x00FFFF | Boot block, **not in the update file** (sets r15, see below) |
| 0x010000-0x027BCF | Vector table (reset -> 0x01E138), startup, operating system; range list at 0x0103D0 |
| 0x03C440-0x0539FF | Constant tables: signal descriptors 0x040AF2, message list 0x041B80, RAM pointer table 0x042D98, calibration module pointers 0x052C0C |
| 0x053A00-0x099FFF | Code |
| 0x0C0000-0x0FCFFF | Calibration (`.0da`); DTC table 0x0CC5EA |
| 0x100000-0x13FFFF | Code (block header at 0x100000 -> next block 0x404000) |
| 0x404000-0x47FFFF | Code (block header -> 0x0C0000) |
| 0x6F8000-0x707FFF, 0x7F0000-0x80FFFF, 0x8FD000-0x8FFFFF | RAM (stack top 0x800000) |
| 0x10C0000-... | RAM copy of the calibration (working page; a second pointer table at 0x052BF0 points there) |

Base registers (`out/bases.json`):

| Register | Value | Evidence |
|---|---|---|
| r13 | 0x7FFFF0 | Set at 0x01DDD8 |
| r2 | 0x0480F0 | Set at 0x01DDE0 / 0x01CD24. An alternative 0x0F80F0 (0x01CD10) is used only when `fn_012018` returns 1; 0x0480F0 gives valid targets for 1566 of 1611 r2 accesses |
| r14 | 0x04653C | Set together with r2 (alternative 0x0F443C) |
| r15 | 0x052C0C | Not set in the supplied code (boot block). It is the only base for which all 427 offsets used with r15 (`lwz rX, off(r15)`) give calibration or constant pointers; it is the calibration module pointer table |

## Tools

| Tool | Purpose |
|---|---|
| [`tools/build_bins.py`](tools/build_bins.py) | Converts all `.0pa`/`.0da` files (with [`../DDE41A-RE/tools/hex2bin.py`](../DDE41A-RE/tools/hex2bin.py)) into flat 0x000000-0x47FFFF images and the combined program + data image |
| [`tools/mem.py`](tools/mem.py) | Memory model and paths |
| [`tools/ppcdis.py`](tools/ppcdis.py) | PowerPC disassembly and cross references (copy of the DDE5.1 tool); writes `out/listing.asm`, `functions.csv`, `xrefs.json`, `calls.json` |
| [`tools/can63.py`](tools/can63.py) | Message list, signal descriptors, 0x0B5 signal reads, gearbox fault paths and calibration; writes [`out/can.md`](out/can.md) |
| [`tools/egs191.py`](tools/egs191.py) | GS19.11 transmission calibration (program 7556246A, 19 data files incl. M67D44 `A7524745`): object table, curves/maps, engine-dependence classes and the diesel-only objects; writes [`out/egs191_cal.md`](out/egs191_cal.md) and `egs/egs191_objects.json` (images in `egs/bin`) |

Run order (from `tools/`): `python build_bins.py`, `python ppcdis.py`, `python can63.py`. SGBD tables were extracted with [`../DDE41A-RE/tools/sgbd.py`](../DDE41A-RE/tools/sgbd.py) into `sgbd/` (master), `sgbd/slave/` and `sgbd/flash/`.

Current output: 2678 functions, 286,658 instructions, 16,581 referenced addresses, 13,438 call sites.

## CAN configuration

**Message list** (0x041B80, 16-byte entries: ID, `01`, bus, object, direction, length, flags). Bus 0 and bus 2 are PT-CAN controllers, bus 1 is the private master/slave CAN (0x511, 0x320).

| Bus | Receives | Transmits |
|---|---|---|
| 0 | 0x0B6, 0x0BA, 0x1A0, 0x1B5, 0x2F8, 0x0C4, 0x194, 0x0BF, 0x0B7, 0x0B9, 0x0BD, 0x2FA, **0x0B5 (object 12, length 8)**, 0x2E4, 0x335/0x315/0x310/0x330/0x331/0x334/0x3B4/0x395 (shared object 14), 0x580 | |
| 1 | 0x320 | 0x511, 0x320 |
| 2 | 0x0CE, 0x135, 0x1AC, 0x1B4, 0x130, 0x19E, **0x1A2 (length 2)** | 0x0A8, 0x0A9, 0x0AA, 0x1D0, 0x1B6, 0x200, 0x332, 0x381, 0x592, 0x3B3, 0x38E, 0x0B4, 0x0AC, 0x3B4 |

A last block (0x041F10-0x041FC0) holds the E38/E53-style messages (transmit 0x316, 0x329, 0x545, 0x170; receive 0x43F EGS1, 0x43B EGS2, 0x613, 0x615, 0x153, 0x1F0, 0x1F3, 0x1F8), matching the SGBD faults "Botschaft (EGS1)" / "(EGS2)".

**Signal descriptors** (0x040AF2, 494 entries of 6 bytes: handle u16, record, type, start bit, length; type 2 = Intel byte order). Readers: `fn_4109C0` (raw), `fn_42B718` / `fn_42B7E4` (scaled: phys = raw x factor / 1000 + offset, parameters from a calibration block), `fn_410948`, `fn_45DDEC`, and the checksum/alive helpers `fn_42BBEC` / `fn_42BAF8`.

## Gearbox torque interface (`TORQUE_GEARBX` 0x0B5)

### Decoding

Record 1 carries exactly the 0x0B5 layout documented in [HeinrichG-V12/E65_ReverseEngineering](https://github.com/HeinrichG-V12/E65_ReverseEngineering/blob/main/docs/0x0B5.md). All signals that matter are read in the PT-CAN receive task `fn_42C0D0` (4888 instructions, scheduled):

| Handle | Bits | Signal | Read at | Result |
|---|---|---|---|---|
| 0x070 | 0-7 | `CHKSM_TORQ_EGS` | 0x42D9A0 (`fn_42BBEC`) | checksum check, 0x8FE3B8 |
| 0x071 | 8-11 | `ALIV_TORQ_EGS` | 0x42D9DC (`fn_42BAF8`) | alive check, 0x7FBC2B |
| 0x072 | 12-23 | `TORQ_TAR_EGS` | 0x42DA84 | 0.1 Nm (raw x 5); raw 0x800 = invalid; -> **0x7F8E6E** (default -0x8000) |
| 0x073 | 24-35 | `TORQ_TAR_ADJR_POS_EGS` | 0x42DAB4 | 0.1 Nm; raw 0x800 = invalid; default calibration 0x0DB9E6 = 1000 Nm; -> **0x7F8E74** |
| 0x074 | 36-37 | `ST_TORQ_TAR_EGS` | 0x42DA50 | 3 = invalid; -> **0x7F88FF** |
| 0x076 | 40-43 | `ST_OBD_GRB` | 0x42DADC | 0x8FE574; values 0/2/4/6/12 drive the MIL request flags (paths 0xBE/0xBF) |
| 0x078 | 46-47 | `ST_LIM_STORQ` | 0x42DC3C | -> 0x7F8901 |
| 0x079 | 48-55 | `TORQ_DRAW_GRB` | 0x42DC6C | 0.1 Nm, negated -> 0x7F8E70 |
| 0x07A | 56-63 | `TEMP_GRB` | 0x42DCA4 | 0.1 K (raw x 10 + 2331, i.e. offset -40 °C) -> 0x7F8E4A; path 0x1EA |

The scaling parameters come from the receive calibration block `*(r15+0x2C0)` = 0x0DB5EC (`+0x34`: offset 0, factor 5000; `+0x70`: 2331/10000; `+0x80`: 0/5000). The error word of the message goes to 0x7F8E36 and fault path 0xC3.

Record 10 (handles 0x03F-0x049) still holds the DDE5.1 layout of 0x0B5 (12 bits at 0, ...); only 0x049 (bits 40-63) is read, in `fn_4327B0`, and compared with 0xFFFFFF, like handle 0x9E in the DDE5.1. Handles 0x156-0x167 (also record 1) are an alternative layout read by `fn_429EF4`.

### Request evaluation (`fn_42C0D0`, 0x42FBA0-0x42FC84)

With the calibration flag `0x0DB5EC+0x389` = 1 (set in all three data files):

- A request is valid only if `TORQ_TAR_ADJR_POS_EGS` differs from its default (1000 Nm) and `ST_TORQ_TAR_EGS` is 1 or 2.
- `ST_TORQ_TAR_EGS` = 1 (**increase torque**): `0x7F8E72` = min(`TORQ_TAR_EGS`, `TORQ_TAR_ADJR_POS_EGS`), otherwise -0x8000.
- `ST_TORQ_TAR_EGS` = 2 (decrease torque): `0x7F8E6C` = `TORQ_TAR_EGS`, otherwise 0x7FFF.
- `0x7F8E74` = `TORQ_TAR_ADJR_POS_EGS` is kept as an additional upper limit.

### Preparation (`fn_13BF80`, `fn_13BB10`, calibration `*(r15+0x2E0)` = 0x0DBD14, `*(r15+0x2E4)` = 0x0DBD74)

| Output | Computation |
|---|---|
| **0x7F8EAA** gearbox minimum torque (increase) | 0x7F8E72 minus RAM 0x7F989C (flag `0x0DBD14+0`=1; 0x7F989C is written by `fn_41A964`/`fn_41B274`/`fn_41B4F8`, not identified), capped at `+0x50` = 32767 (no cap), then ramp switch `fn_45AD50`: switch = FId 0xC7 permission (bit 0 of 0x6F8565, function-inhibit array 0x6F849E), fallback `+0x52` = -32768, slopes `+0x54` = 0x00050000 (10 Nm per 20 ms, only while switching). Initialised to -500 Nm |
| **0x7F8EA4** gearbox maximum torque (reduction) | 0x7F8E6C ramped (`+0x48`) against a ceiling: `+0x02` = 0x7FFF above RAM 0x7F9324 > `+0x5C`, otherwise curve `+0x04` over 0x7F98C4 (200-6000, all 1000 Nm). Initialised to 1000 Nm |
| **0x7F8EA8** gear-dependent maximum | min(per-gear curve over 0x7F98C4, ramped with `+0x04`; `TORQ_TAR_ADJR_POS_EGS`; start-up limit when `ST_LIM_STORQ` requests it). Gear from 0x7F890D (-1..6) |
| 0x7F8EA6 drag torque | 0x7F8E70 when 0x7F8910 = 1, else 0 |

Per-gear curves (0.1 Nm, all flat): R 400 Nm (0x0DC04A), 1st-6th 750 Nm (0x0DBED6, 0x0DBF14, 0x0DBF52, 0x0DBF90, 0x0DBFCE, 0x0DC00C), N/other 700 Nm (0x0DBDA4). Identical in the 220 kW and 242 kW data.

### Torque coordinator (`fn_059CDC`, `fn_059A88`)

```
x = driver/vehicle demand + TORQ_DRAW_GRB          (0x7F8BC6)
x = min(x, 0x7F8EA8)                               gear / ADJR_POS / start-up limit
x = max(x, 0x7F8EAA)                               gearbox increase request  (downshift blip)
x = min(x, 0x7F8C2E)                               other limit (fn_058FA8)
x = min(x, 0x7F8EA4)                               gearbox reduction request
-> 0x7F8BBA, + 0x7F8BB0 -> 0x7F8BBE
```

The routine at 0x059564 ranks the active intervention (code 6 = gearbox reduction, 5 = gearbox increase, ...) into the bit word 0x7F932C. The driveability mode selectors `fn_064664` (calibration 0x0C8FB8) and `fn_40D35C` use bits 3-6 ("external intervention active") as their first condition; in that mode `fn_064664` loads the torque gradient limits 0x7F9360-0x7F9366 from `+0x22`/`+0x24` (32767 = unlimited; read by `fn_40D868`). `fn_4313F8`, which builds the transmitted engine torque signals (records 3-5), could also raise its value to 0x7F8EAA, but the switch for this (`0x0DB5EC+0x37F`) is 0 in this calibration; the transmitted value is only clamped at -500 Nm.

**Result:** the downshift blip is a minimum-torque request from the EGS (`ST_TORQ_TAR_EGS` = 1, target in `TORQ_TAR_EGS` limited by `TORQ_TAR_ADJR_POS_EGS`). The DDE6.3 applies it as a `max()` in the torque coordinator after the gear limit, so the per-gear curves limit the driver demand but not the blip. It has no calibrated blip amount or duration of its own, and its cap (`+0x50`) is open. The size and timing of the blip are set entirely by the transmission calibration. Function description: [Function-Description-EGS-Torque-Intervention.md](Function-Description-EGS-Torque-Intervention.md).

### Fault paths (DTC table 0x0CC5EA, 8 bytes per path)

| Path | DTC | SGBD text | Source |
|---|---|---|---|
| 0x0BE | 3F05 | MIL OFF | `ST_OBD_GRB` |
| 0x0BF | 3F15 | MIL On | `ST_OBD_GRB` |
| 0x0C3 | 4DF0 | Botschaft (TORQUE_GEARBX, 0xB5) | checksum, alive, signal errors (error word 0x7F8E36) |
| 0x1EA | 41B5 | Fault path for Gearbox Temperature | `TEMP_GRB` |

## Open points

- Measurement labels: the 908-entry RAM pointer table at 0x042D98 is not yet mapped to the SGBD measurement IDs (IDs up to 0x1B6E), so Bosch labels (`CoVM_trqPrpDes`, `CoEng_trqInrSet`, ...) are not attached to the RAM cells above.
- 0x7F989C (subtracted from the increase request) and 0x7F8C2E (third limit) are not identified.
- Record-to-bus/object mapping is inferred from the signal layouts and fault paths, not from the driver code.
- Transmission side: the GS19.11 calibration for the M67D44 (`A7524745`) is decoded structurally, but the blip parameters could not be identified because the GS19.11 code is encrypted and the data has no labels (see [M67-DDE63-Findings.md](../M67-DDE63-Findings.md#transmission-side-gs1911-calibration-m67d44)).
