# DDE5.1 (EDC16C1, early M67D39 / E65 740d) master: reverse engineering (in progress)

Static analysis of the E65 740d M67D39 DDE5.1 software from SP-Daten v60.1 (`E65\data\DDE51`):

| | |
|---|---|
| Program | [`7809330A.0pa`](../../Shared/SP-Daten/E65/data/DDE51/7809330A.0pa): EDC16C1, project "M67D/E65", 190 kW, AT; Bosch SW 1037390909 |
| Data | [`V7810913.0da`](../../Shared/SP-Daten/E65/data/DDE51/V7810913.0da) (reference `0089EI0AQK1BEY220`, assembly 7810911) |
| Diagnostic SGBD | [`D51MM670.prg`](../../Shared/SP-Daten/E65/ecu/D51MM670.prg) (master); slave `D51SM670.prg` |
| CPU | Freescale MPC5xx (PowerPC, big-endian, 448 KB internal flash) |

The second data file `V7810912.0da` (`...EY200`, assembly 7810910) is not the slave calibration: it differs from `V7810913` only in two calibration bytes (0x8F682A: 0x32 vs 0x30, 0x8F6F12: 0x32 vs 0x64), the reference string, signature and checksums. Master and slave run the same program and data.

## Memory map

| Address | Content |
|---|---|
| 0x000000-0x007FFF | Internal flash boot area (not in the update file) |
| 0x008000-0x00FFFF | Constant tables: CAN/COM configuration (0x8000-0x9A00), CAN signal descriptors 0x896C, measurement address table 0xA1A4 |
| 0x010000-0x06FFFF | Code (internal flash) |
| 0x3F9800-0x3FFFFF | Internal SRAM (zeroed and initialised by the startup code at 0x8212F8) |
| 0x400000-0x4FFFFF | External RAM |
| 0x800000-0x81FFFF | External flash, **not in the update file** (boot/operating system: 460 calls to 103 routines, e.g. 0x813000, 0x81DA64) |
| 0x820000-0x82003F | Program header (`5A5A5A5A 33333333`, range list at 0x820180, entry jump 0x8202E0 -> 0x8212F8) |
| 0x820000-0x87FFFF | Code (external flash; 0x830000 block empty) |
| 0x8DFE00-0x8FFBFF | Calibration data (signature 0x8DFF04, ID strings 0x8E0010) |

Base registers (`out/bases.json`):

| Register | Value | Evidence |
|---|---|---|
| r2 | 0x0100F0 | Set at 0x821A88 (`lis r2,1; addi r2,r2,0xF0`); the CAN signal table at r2-0x7784 = 0x896C confirms it |
| r14 | 0x8261AC | Set at 0x821A90 |
| r13 | 0x409800 (assumed) | Set in the unsupplied boot code. The small-data window lies above the last absolute RAM access (0x4017F0); 4-byte alignment is certain, the exact value is not |

## Tools

| Tool | Purpose |
|---|---|
| [`../DDE41A-RE/tools/hex2bin.py`](../DDE41A-RE/tools/hex2bin.py) | Hex to binary; handles the combined 02/04 address records and the type-0x10 block-trailer records of these files |
| [`tools/mem.py`](tools/mem.py) | Memory model (internal flash, external flash, calibration) and paths |
| [`tools/ppcdis.py`](tools/ppcdis.py) | PowerPC disassembly (capstone), function detection, register constant tracking (lis/addi/ori, r2/r13/r14, callee-saved bases), indexed accesses; writes `out/listing.asm`, `functions.csv`, `xrefs.json`, `calls.json` |
| [`tools/maps51.py`](tools/maps51.py) | Curves/maps from all lookup call sites (with traced input variables and value order) plus a structural scan of the calibration; writes `out/maps.md`, `maps.csv`, `maps.json` |
| [`tools/egs_can.py`](tools/egs_can.py) | Converts the GS19.02/GS19.04 transmission programs (`egs/bin`), extracts their CAN message lists and compares them with the DDE list; writes `out/egs_can.md`. Decoded GS19 SGBDs are in `egs/GS19*` |
| [`tools/egs_cal.py`](tools/egs_cal.py) | Decodes the GS19.04 calibration (pointer table, objects, curves/maps) and compares the M67D40 data with the M57/N62/N73 variants; writes `out/egs_cal.md`, `egs/egs_objects.json` |

Run order: `python ppcdis.py`, then `python maps51.py` (from `tools/`).

Current output: 1815 functions, 178,130 instructions, 12,812 referenced addresses, 7327 call sites; 645 curves/maps (376 KL, 269 KF), 483 of them referenced by lookup calls.

## Findings so far

**Interpolation routines.** Curves: `fn_0583BC` (r3 = x, r4 = curve, r5 = index cache; layout `n, x[n], y[n]`, signed 16-bit). Maps: `fn_0584B4` (r3 = x, r4 = y, r5 = map, r6 = cache; layout `nx, ny, x[nx], y[ny], z`). Group curves (shared axis): `fn_058388` interpolates a value table from a precomputed 16.16 axis position.

**Measurement table.** 0x00A1A4 holds 523 RAM addresses indexed by the SGBD measurement ID (`STATUS_MESSWERTBLOCK` / `2C 10 <ID>`); e.g. `InjVlv_nCyl1..6` (IDs 0xA1-0xA6) map to 0x4004A6-0x4004B0. The SGBD gives Bosch label names for all 220 IDs (`CoVM_trqPrpDes`, `CoEng_trqInrSet`, `ASDdc_trq`, `Gearbx_stGear`, ...). The addressed block 0x400364-0x40091D is written by code that isn't visible (only one address reference), so these labels can't be attached to code yet. 1842 of the absolutely addressed RAM locations are only ever written, i.e. most of 0x400000-0x4017FF holds measurement copies.

**CAN receive path** (gearbox messages, IDs from the SGBD fault texts):

| Message | ID | Receive object | Signal handles (descriptor table 0x896C, 6 bytes each) |
|---|---|---|---|
| `TORQUE_GEARBX` | 0x0B5 | **23** (0x17), filled by the gateway | 0x3C 0+8 checksum, 0x3D 8+4 alive, 0x3E 12+12 `TORQ_TAR_EGS`, 0x3F 24+12 `TORQ_TAR_ADJR_POS_EGS`, 0x40 36+2 `ST_TORQ_TAR_EGS`, 0x41 38+2, 0x42 40+4 `ST_OBD_GRB`, 0x43 44+2, 0x44 46+2 `ST_LIM_STORQ`, 0x45 48+8 `TORQ_DRAW_GRB`, 0x46 56+8 `TEMP_GRB` |
| (legacy) | 0x0B5 | 7 (object length 5) | Old layout: 0x94 bits 0-11 ... 0x9D 32-39, 0x9E 40-63; only 0x9E is read |
| `GEARBX_DATA` | 0x0BA | 8 | 0x9F bits 0-7, 0xA0 8-9 |
| `GEARBX_DATA2` | 0x1A2 (object length 7; GS19.02/GS19.04 send 2 bytes) | 9 | 0x4B bits 0-11, 0x4C 28-39 (0x4C not supplied by GS19) |
| `TORQUE_DSC` | 0x0B6 | 6 | 0x33-0x36 |

- Receive interrupt handlers at 0x02DDCC-0x02E05C (one per object; object 7 handler 0x02DE0C) copy the data with `fn_05B858` into records of 0x14 bytes at `*(0x401DAC) + 0x14·object` and set a new-data flag.
- Signal reads go through `fn_05AC98(handle)` and the wrappers `fn_059CF0`, `fn_02DD14`, `fn_02DC2C`.
- **0x0B5 is decoded from record 23 (0x17)**, which carries the documented 8-byte layout (below). The gateway `fn_043D90`/`fn_044130` (route table 0x00DAE8: records 0x15/0x16/0x17 -> 6/4/5) copies record 0x17 into record 5, the 5-byte private-CAN transmit entry (#05 in list 0x9524), so the slave receives bits 0-39 (checksum, alive, both torque targets and the status).
- Record 7 has an older 0x0B5 layout (handles 0x94-0x9E). It is read raw once (`fn_05ADA4(7)`, copies to the write-only bytes 0x400B8F-0x400B96), timeout-checked (`fn_05A734(7)`, path 0x6B = 4DF0) and only 0x9E (bits 40-63) is compared with 0xFFFFFF.

An earlier version of this README stated that 0x0B5 is not decoded in visible code. That was wrong: the search only compared against the record 7 handles 0x94-0x9E.

### 0x0B5 decoding (`fn_02E490`, 0x02FE7C-0x0304E4)

| Handle | Signal | Read at | Result |
|---|---|---|---|
| (record) | raw copy | 0x02FE80 `fn_05ADA4(0x17)` | measurement bytes 0x400BEC-0x400BF3; fault path 0x76 |
| 0x3C / 0x3D | checksum / alive | 0x02FFD4 / 0x030078 | message checks, fault paths 0x71 / 0x72 |
| 0x40 | `ST_TORQ_TAR_EGS` | 0x03018C | r23, 3 = invalid -> 0x402086 |
| 0x3E | `TORQ_TAR_EGS` | 0x0301C4 (`fn_02DC2C`, scaling 0x8EAAA8: factor 5000/1000, i.e. 0.5 Nm raw -> 0.1 Nm) | r17, raw 0x800 = invalid -> 0x40241E |
| 0x3F | `TORQ_TAR_ADJR_POS_EGS` | 0x0301F0 | -> **0x402424** |
| 0x42 | `ST_OBD_GRB` | 0x030230 | MIL request, path 0x66 = 3F05 "MIL OFF" |
| 0x44 | `ST_LIM_STORQ` | 0x030328 | -> 0x402088 |
| 0x45 | `TORQ_DRAW_GRB` | 0x030364 (scaling 0x8EAAD8) | negated -> **0x402420** |
| 0x46 | `TEMP_GRB` | 0x0303A0 (scaling 0x8EAACC: x 10 + 2331 = 0.1 K) | -> 0x402402 |

Request evaluation at 0x0304A4: if the status and torque are valid, `ST_TORQ_TAR_EGS` = 1 gives **0x402422 = `TORQ_TAR_EGS`** (minimum-torque / increase request, otherwise -0x8000) and `ST_TORQ_TAR_EGS` = 2 gives **0x40241C = `TORQ_TAR_EGS`** (maximum-torque / reduction request, otherwise 0x7FFF). Unlike the DDE6.3, the increase is not limited by `TORQ_TAR_ADJR_POS_EGS` here; that signal only enters the gear limit below.

### 0x0B5 layout

The community decoding of 0x0B5 from a Bosch document, checked on a 2006 760Li with MED 9.2.1 ([HeinrichG-V12/E65_ReverseEngineering](https://github.com/HeinrichG-V12/E65_ReverseEngineering/blob/main/docs/0x0B5.md)), is (Intel byte order, DLC 8, 10 ms):

| Bits | Signal | Scaling |
|---|---|---|
| 0-7 | `CHKSM_TORQ_EGS` checksum | |
| 8-11 | `ALIV_TORQ_EGS` alive counter | |
| 12-23 | `TORQ_TAR_EGS` torque request | signed, 0.5 Nm |
| 24-35 | `TORQ_TAR_ADJR_POS_EGS` torque request, positive intervention | signed, 0.5 Nm |
| 36-37 | `ST_TORQ_TAR_EGS` | 0 none, **1 increase torque**, 2 decrease torque, 3 invalid |
| 38-39 | `ST_OTMP_GRB` overtemperature | |
| 40-47 | `ST_OBD_GRB`, `ST_OTMP_ERR_GRB`, `ST_LIM_STORQ` | |
| 48-55 | `TORQ_DRAW_GRB` gearbox drag torque | 1 Nm |
| 56-63 | `TEMP_GRB` | 1 °C, offset -40 (example: raw 0x43 = 27 °C) |

Record 23 matches this layout bit for bit. The record 7 descriptors 0x94-0x9E (12 bits at 0, 2-bit fields at 12/14, 3-bit fields at 16/19, 8 bits at 32) describe a different, probably older, message definition and are dead entries apart from the 0x9E check.

### Fault path table

The calibration holds the DTC per fault path at **0x8E4A4C** (8 bytes per path = 4 DTCs). Path 0x6B = 4DF0-4DF3 confirms the layout. Paths relevant here:

| Path | DTC | SGBD text | Reported by |
|---|---|---|---|
| 0x5A | 4BE0 | `GEARBX_DATA` 0x0BA | |
| 0x5B | 4BE5 | `GEARBX_DATA2` 0x1A2 | |
| 0x66 | 3F05 | MIL OFF | `fn_02E490` (`ST_OBD_GRB` of 0x0B5) |
| 0x6A | 4C20 | `TORQUE_DSC` 0x0B6 | |
| 0x6B | 4DF0 | `TORQUE_GEARBX` 0x0B5 | `fn_02E490` (record 7 timeout, 0x9E check) |
| 0x71, 0x72, 0x76 | 4210, 4220, 4260 | (no SGBD text) | `fn_02E490` (record 23 message checks) |
| 0x6C | 45F5 | `DREHMOMENT_ANF_ACC` 0x0B7 | |
| 0x6F | 4920 | "Momenteneingriff Getriebe (nv)", fault type 0x10A0 "Eingriff unplausibel" | `fn_869B88` (init), `fn_869C54` |
| 0xBA | 4405 | "Master/Slave faultpath for EGS error (torque switch off)" | `fn_046214` |

Path 0x6F is **not** a gearbox intervention. `fn_869C54` reports it for receive object 11 = **0x19E (DSC status)**: handles 0xA4 (bits 0-11, raw x 10 via `fn_02DD14`/0x8EAAB0, -> 0x402434, 0x8000 = invalid), 0xA5 (bits 12-13 -> 0x402089), 0xA6 (bits 18-20, valid 0/1/2/4, default 7 -> 0x40208A; these values are the `ST_DSC` states clear/passive/faulty/traction/invalid) and 0xA7 (alive counter). The values are used by `fn_020634` and `fn_857D64`. "(nv)" in the SGBD text is most likely "nicht verwendet" (unused), as for 4900 "Momenteneingriff DSC (nv)", so the text is a leftover.

Also not read in the visible code: 0x4B (0x1A2 bits 0-11).

## Downshift blip (positive engine intervention)

The blip is implemented exactly as in the DDE6.3 ([M67-DDE63-Findings.md](../M67-DDE63-Findings.md)): the EGS sends the torque it wants (`ST_TORQ_TAR_EGS` = 1, target in `TORQ_TAR_EGS`), and the DDE raises its torque request to at least that value. The DDE has no blip amount or duration of its own.

| Step | DDE5.1 | Function | DDE6.3 equivalent |
|---|---|---|---|
| Decode | 0x402422 increase, 0x40241C reduction, 0x402420 drag, 0x402424 `TORQ_TAR_ADJR_POS_EGS` | `fn_02E490` (above) | `fn_42C0D0` |
| Increase request | **0x402452** = ramp switch (`fn_0588D4`) between 0x402422 and the fallback 0x8EAE60 = -32768 (no request); switch = bit 0 of 0x409990 (permission flag); slopes 0x8EAE64 = 0x00050000 up/down | `fn_856C5C` | `fn_13BF80`, 0x7F8EAA |
| Reduction request | 0x40244C = ramp switch between 0x40241C and a ceiling (0x8EAE14 = 32767 above 0x4026BE > 0x8EAE6C, else curve 0x8EAE16 over 0x402902, all 32767); slopes 0x8EAE58 | `fn_856C5C` | 0x7F8EA4 |
| Gear limit | 0x402450 = min(per-gear curve over engine speed 0x402902, `TORQ_TAR_ADJR_POS_EGS`); gear from 0x402092 (-1..6): R 0x8EB114, N/other 0x8EAE6E, 1st-6th 0x8EAFA0/0x8EAFDE/0x8EB01C/0x8EB05A/0x8EB098/0x8EB0D6 (all 700 Nm), alternatives 0x8EAF3A/0x8EAED4 (1000 Nm) | `fn_856888` | `fn_13BB10`, 0x7F8EA8 |
| Drag torque | 0x40244E = 0x402420 when 0x402094 = 1 | 0x856D18 | 0x7F8EA6 |
| Coordinator | x = demand - 0x40244E; min(x, 0x402450); **max(x, 0x402452)**; min(x, 0x40244C) -> 0x402248; + 0x40223E -> 0x40224C | `fn_85D864` | `fn_059CDC` |

Initial values (0x856C30): reduction 1000 Nm, increase -500 Nm.

**Ramp switch timing:** `fn_0588D4` only ramps when the switch changes (permission granted/withdrawn); while it is granted, the EGS request passes through unchanged. The ramp step is slope x round(dt/1000) >> 16 with dt = 20000 µs, i.e. 5 x 20 = 100 units = 10 Nm per 20 ms (500 Nm/s).

So the shape of the blip on the engine side is: EGS target torque (from the GS calibration) -> max() with the driver demand, which has already been limited by the per-gear curve (700 Nm) -> reduction request -> general torque limits -> torque-to-quantity conversion. Because the `max()` comes after the gear limit (0x85D8BC-0x85D8F8), the per-gear curve doesn't cap the blip, and unlike the DDE6.3 the increase isn't limited by `TORQ_TAR_ADJR_POS_EGS` either. The DDE-side tables that can change it are the ramp slopes 0x8EAE64 (only on enable/disable), the reduction ceiling and the general torque limiter / smoke limit.

### Structural candidates from the map scan

Tables over the **gear axis** `[-1, 0, 1, 2, 3, 4, 5, 6]` (reverse, neutral, gears 1-6) and other shift-related shapes:

| Table | Function | Content | Interpretation |
|---|---|---|---|
| 0x8EAD8C KF 4x8 | `fn_86AC50` | x = RAM 0x4023BC (60, 1060, 1300, 1450), y = gear (RAM 0x402092); 0 in R/N, 950-1300 in gears 1-6; PT1-filtered with 0x8EAD84, output RAM 0x402446; active when 0x402094 = 1 | Gear-dependent load (shape fits converter/drive-engagement pre-control at idle); not a blip |
| 0x8E38CC / 0x8E38EE / 0x8E3910 KL 8 | `fn_8585C0` | Constant 250 / 50 / 50 over gear; same function uses 0x8E3B12 (x 0-175, values 819-1802) | Probably cruise control parameters per gear |
| 0x8E8004 KL 8 | `fn_02BFD8` | All zero over gear | Per-gear torque limit, not used in this calibration |
| 0x8E8026, 0x8E807C, 0x8E80D2, 0x8E8152 KL 21 | `fn_02BFD8` | Over engine speed 600-5000: 4000 -> 6540 -> 0 (0x8E807C cuts to 0 from 4000 rpm) | Torque limiter full-load curves |
| 0x8E7F26, 0x8E81A8, 0x8E7E5C KF 9x9 | `fn_02BFD8` | Axis 2732-3987 (0-125 degC in 0.1 K); 8192 = factor 1.0 | Temperature derating of the torque limit |
| 0x8E9970, 0x8E9B18, 0x8E9BDE KF 8x8 | `fn_02CA1C`, `fn_02D544` | Signed y axes (-2000..1500, -4000..500, -341..341); values constant 16777 (0x8E9970) and 7872-8512 | Correction factors over a signed quantity (gradient or deviation) |
| 0x8E277E, 0x8E2822 KF 4x7 | `fn_855C00` | y = -6000..6000, values 180-540 | Signed-axis maps, function not identified |

None of these has the shape of a downshift blip; the blip path is the one described above.
