# BMW M67 DDE6.3 (EDC16CP35): Findings from BMW SP-Daten v60.1

Analysis of the E65 745d (M67TUE / M67D44, 220 and 242 kW) diesel engine control unit data in [`BMW-SPdaten-v.60.1/E65`](BMW-SPdaten-v.60.1/E65), with the focus on the gearbox torque interface. The reverse engineering is in [`DDE63-RE/`](DDE63-RE/README.md). For the earlier M67D39 unit see [M67-DDE51-Findings.md](M67-DDE51-Findings.md).

## DDE6.3 system overview

Like the DDE5.1, the M67TUE uses two Bosch control units in a master/slave arrangement at diagnostic addresses 12h/13h (`kmmData/kmm_HO.txt`: `12/13:DDE63`). Both run the same program and calibration.

| Role | Folder | Diagnostic SGBD | Flash SGBD (WinKFP) | Flash parameter file |
|---|---|---|---|---|
| Master | [`data/DDE63`](BMW-SPdaten-v.60.1/E65/data/DDE63) | `ecu/D63MM670.prg` "DDE 6.3 fuer M67TUE" (revision 12.04, 143 jobs) | `ecu/09DDE63.PRG` "Spezial SGBD nur fuer Flashen DDE63" (revision 2.50, 50 jobs) | `sgdat/13DDE63.IPO` |
| Slave | same | `ecu/D63SM670.prg` (143 jobs) | same | same |

The master and slave SGBDs have the same job list; of their tables only `LERNWERTE_RUECK` and `TINDIVIDUALDATALISTE` differ.

`kmmData/kmm_SG.txt` lists `DDE__41_M67__8Z_DDE63__D44_1`, `DDE__41_M67__8Z_DDE63__D44 220KW` and `DDE__41_M67__8Z_DDE63__D44 242KW`.

## Vehicle assignment

`DDE63.ATS` (09.05.2007, TAIS query from 26.04.2007) has one entry: type code `HM61` -> assembly **7808735** (`SE`).

## Software release

`DDE63.DAT` (05.04.2007):

| Assembly number | Type number | Hardware number / index | Software number | Variant flag | Data file | Output (`K_F3`) |
|---|---|---|---|---|---|---|
| 7802234 | 7794616 | 7801218 / A | 7802235DA | 8 | `T7802235.0da` | 220 kW |
| **7808734** | 7794616 | 7808738 / A | 7808736DA | 5 | `T7808736.0da` | 220 kW |
| **7808735** | 7801032 | 7808738 / A | 7808737DA | S | `T7808737.0da` | 242 kW |

### Release details

| | Program `7801218A` | Program `7808738A` | Data `T7802235` | Data `T7808736` | Data `T7808737` |
|---|---|---|---|---|---|
| BMW reference | `0089R10A9G2B` | `0089R10A9G3B` | `...G2BEZ140` | `...G3BEZ220` | `...G3BEZ300` |
| File checksum | E027 | 89F4 | A933 | BABF | 9653 |
| Variant text (`K_V2`) | `V9G.2 E65-06-03-400` | `V9G.3 6x-07-09-500` | `V9G.2 E65-06-03-500` | `V9G.3 6x-07-09-500` | `V9G.3 6x-07-09-500` |
| Bosch file | `O_04Z9G2.H383` | `O_22Z9G3.H383` | `O_14Z9G2.H383` | `O_22Z9G3.H383` | `O_30Z9G3.H383` |
| BMW approval | 16.08.2005 | 09.05.2007 | 09.11.2005 | 09.05.2007 | 09.05.2007 |

All headers read `ZL_System: EDC16CP35`, `ZL_Projekt: M67TUE/E65`, `K_F1 E65`, `K_F2 AT`, `K_V1 M67TUE`, Bosch release number (hardware) `0 281 012 479`. The block headers contain the Bosch software number 1037390116.

Differences:

- `7801218A` vs. `7808738A`: 152,784 bytes. Both have the same CAN signal table (the 0x0B5 descriptors are at 0x040D92 in both).
- `T7808736` (220 kW) vs. `T7808737` (242 kW): 240 bytes in 19 ranges (0x0D5D9E-0x0D65EF, 0x0D997F-0x0D9A63, plus ID strings and checksums); none in the gearbox interface.
- `T7802235` vs. `T7808736`: 265 bytes.

### Flash memory layout

| Area | Content |
|---|---|
| 0x000000-0x00FFFF | Boot block, **not in the update file** |
| 0x010000-0x0BFFFF | Program: startup and vector table (0x010000), constant tables (0x03C440-0x0539FF), code (0x053A00-0x099FFF) |
| 0x0C0000-0x0FCFFF | Calibration (`.0da`) |
| 0x100000-0x13FFFF | Program (code) |
| 0x404000-0x47FFFF | Program (code) |

The program range list at 0x0103D0 has five ranges: 0x10000-0x1024F, 0x103D0-0x3FFBF, 0x40000-0xBFFFF, 0x100000-0x13FFFF, 0x404000-0x47FFFF. The block headers link 0x100000 -> 0x404000 -> 0x0C0000. Each `.0pa` covers about 1.23 MB, each `.0da` 235,700 bytes.

In contrast to the DDE5.1, the operating system and startup code are part of the update file; only the boot block is missing.

### Upgrade history

**Assembly history (`DDE63.HIS`, one chain):** 4712802 → 4713563 → 4714151 → 7794282 → 7796641 → 7796690 → 7797284 → 7797286 → 7798359 → 7798435 → 7798724 → 7799173 → 7799175 → 7800990 → 7799889 → 7801333 → 7801335 → 7801723 → 7801739 → 7801766 → 7801768 → 7802234 → 7802232 → 7804316 → 7804314 → 7804345 → 7804343 → 7808734 → **7808735**.

**Hardware history (`DDE63.HWH`):** 4713718A (G), 7792087A (F); 7797452A, 7798426A, 7798723A, 7799155A, 7798185A (F), 7799899A (E), **7801218A** (G), **7808738A** (F).

## Checking the actual car

Run `IDENT` and `AIF_LESEN` on `D63MM670` (master) and `D63SM670` (slave). Expected: program 7808738A with assembly 7808734 (220 kW) or 7808735 (242 kW).

## Bosch labels in the diagnostic SGBD

`D63MM670_MESSWERTETAB` has 545 measurement IDs with Bosch labels, among them `CoVM_trqPrpDes` (propulsion torque request), `CoEng_trqInrSet`, `CoEng_trqInrLtd`, `CoEng_trqLimMin_mp`, `CoEng_stCurrLimActive` (lowest active torque limitation), `AccPed_trqDes`, `CrCtl_trqDes`, `Gearbx_stGear` and `Gearbx_swtType`.

Gearbox-related fault texts (`FORTTEXTE`): `4DF0-4DF3` `TORQUE_GEARBX` 0xB5, `4BE2/4BE3` `GEARBX_DATA` 0xBA, `4BE7/4BE8` `GEARBX_DATA2` 0x1A2, `4C20-4C23` `TORQUE_DSC` 0xB6, `45F5-45F8` `DREHMOMENT_ANF_ACC` 0xB7, `48C2/48C3` `EGS1`, `4AA2/4AA3` `EGS2`, `4405` and `4A6A` master/slave faults for EGS errors, `40C5`/`40CA` master/slave faults for "external desired torque", and again `4920` "Momenteneingriff Getriebe (nv)".

### Flash SGBD `09DDE63.PRG` (50 jobs)

Compared with the DDE5.1 flash SGBD it adds `FLASH_SCHREIBEN_XXL`, `SET_PARAMETER`, `ACCESS_TIMING_PARAMETER(_DEFAULT)` and `EEPROM_LOESCHEN`; programming again uses `AUTHENTISIERUNG_*` and `FLASH_SIGNATUR_PRUEFEN`.

## Reverse engineering of the DDE6.3 release

[`DDE63-RE/`](DDE63-RE/README.md) contains the analysis of `7808738A` with `T7808736`:

- **Disassembly:** 2678 functions, 286,658 instructions; only 5 calls leave the supplied code.
- **Base registers:** r13 = 0x7FFFF0, r2 = 0x0480F0 and r14 = 0x04653C from the startup code; r15 = 0x052C0C (calibration module pointer table, set in the boot block, derived from its 427 uses).
- **CAN:** message list at 0x041B80 (16-byte entries, three controllers), 494 signal descriptors at 0x040AF2; full tables in [`DDE63-RE/out/can.md`](DDE63-RE/out/can.md).
- **Fault paths:** DTC table at 0x0CC5EA (4 DTCs per path).

## Gearbox torque interface

### 0x0B5 is fully decoded

`TORQUE_GEARBX` 0x0B5 is received with **8 bytes** (DDE5.1: 5) and its descriptors match the layout documented in [E65_ReverseEngineering](https://github.com/HeinrichG-V12/E65_ReverseEngineering/blob/main/docs/0x0B5.md). The PT-CAN receive task `fn_42C0D0` reads every relevant signal:

| Signal | Bits | DDE6.3 |
|---|---|---|
| `CHKSM_TORQ_EGS`, `ALIV_TORQ_EGS` | 0-11 | Checksum and alive counter checked, errors to fault path 0xC3 = **4DF0** |
| `TORQ_TAR_EGS` | 12-23 | 0.1 Nm internally, -> 0x7F8E6E |
| `TORQ_TAR_ADJR_POS_EGS` | 24-35 | 0.1 Nm, default 1000 Nm, -> 0x7F8E74 |
| `ST_TORQ_TAR_EGS` | 36-37 | 1 = increase, 2 = decrease, 3 = invalid; -> 0x7F88FF |
| `ST_OBD_GRB` | 40-43 | MIL request from the EGS: paths 0xBE/0xBF = **3F05 "MIL OFF" / 3F15 "MIL On"** |
| `ST_LIM_STORQ` | 46-47 | Start-up torque limitation, -> 0x7F8901 |
| `TORQ_DRAW_GRB` | 48-55 | Gearbox drag torque, added to the torque demand |
| `TEMP_GRB` | 56-63 | Gearbox temperature, path 0x1EA = **41B5** |

The old DDE5.1 descriptor layout of 0x0B5 is still present as a second record (handles 0x03F-0x049) but only its bits 40-63 are read, which suggests the 5-byte layout in the DDE5.1 is a leftover of an earlier E65 message definition.

### How the intervention is applied

1. **Request** (`fn_42C0D0`): with `ST_TORQ_TAR_EGS` = 1 the minimum-torque request is min(`TORQ_TAR_EGS`, `TORQ_TAR_ADJR_POS_EGS`); with 2 the maximum-torque request is `TORQ_TAR_EGS`. A request needs `TORQ_TAR_ADJR_POS_EGS` different from its 1000 Nm default.
2. **Preparation** (`fn_13BF80`): the minimum request (minus RAM 0x7F989C) goes through a ramp switch (`fn_45AD50`) into 0x7F8EAA. The switch is the Bosch function-inhibit permission **FId 0xC7** (bit 0 of 0x6F849E+0xC7): while permitted, the EGS request passes through unchanged; when the permission is withdrawn or granted, the value ramps between the request and "no request" (-32768) at 10 Nm per 20 ms (slopes `0x0DBD14+0x54` = 0x00050000). No calibrated cap (`+0x50` = 32767). The maximum request is handled the same way into 0x7F8EA4.
3. **Gear limit** (`fn_13BB10`): 0x7F8EA8 = min(per-gear curve, `TORQ_TAR_ADJR_POS_EGS`, start-up limit). Curves: R 400 Nm, gears 1-6 750 Nm, other 700 Nm, flat over speed.
4. **Coordinator** (`fn_059CDC`, `fn_059A88`): demand + drag torque, then `min(0x7F8EA8)`, **`max(0x7F8EAA)`**, `min(0x7F8C2E)`, `min(0x7F8EA4)`.
5. **Feedback**: `fn_4313F8`, which builds the transmitted engine torque signals, has an option to include the increase request, but it is switched off in this calibration (`0x0DB5EC+0x37F` = 0).
6. **Driveability**: the routine at 0x059564 marks the active intervention in a bit word (0x7F932C; bit 5 = gearbox increase, bit 6 = gearbox reduction). Two driveability mode selectors, `fn_064664` (calibration `*(r15+0xB0)` = 0x0C8FB8) and `fn_40D35C` (`*(r15+0xA4)`), use "intervention active" (bits 3-6) as their first condition and switch to a dedicated mode. In `fn_064664` that mode loads fixed torque gradient limits (`+0x22`/`+0x24`), which are 32767 (unlimited) in this calibration, so the blip is not slowed by the driveability rate limiter.

**The downshift blip is therefore implemented in the DDE as a minimum-torque request from the EGS** (`ST_TORQ_TAR_EGS` = 1), applied with `max()` in the torque coordinator. The DDE has no own blip table or duration: amount and timing come from the transmission (GS19.11 for the M67D44, `GKE191`). Because the `max()` comes after the gear limit, the per-gear maximum (750 Nm forward, 400 Nm reverse) limits only the driver demand, not the blip. The blip is limited by `TORQ_TAR_ADJR_POS_EGS`, the further limit 0x7F8C2E, an active reduction request and the downstream quantity limits. A full description in the style of the EDC15C function description is in [`DDE63-RE/Function-Description-EGS-Torque-Intervention.md`](DDE63-RE/Function-Description-EGS-Torque-Intervention.md).

### Comparison with the DDE5.1

| | DDE5.1 (`7809330A`) | DDE6.3 (`7808738A`) |
|---|---|---|
| 0x0B5 receive length | 5 bytes | 8 bytes |
| 0x0B5 descriptors | Documented layout in record 23, all relevant signals read; old layout in record 7 unused | Documented layout (record 1), all relevant signals read |
| 0x1A2 receive length | 7 | 2 (matches GS19) |
| Code outside the update file | 0x0-0x7FFF and 0x800000-0x81FFFF (460 calls) | 0x0-0xFFFF only (5 calls) |
| Gearbox increase request | Decoded (`fn_02E490`), ramp-switched (`fn_856C5C`) and applied as `max()` in `fn_85D864` | Decoded, ramped and applied as `max()` in the torque coordinator |
| `4920 "Momenteneingriff Getriebe (nv)"` | Used for 0x19E (DSC status) | Label still present |

## Possible next steps

- Map the RAM pointer table at 0x042D98 to the SGBD measurement IDs, to name 0x7F8EAA, 0x7F8BBA etc. with Bosch labels and log them on the car.
- Identify 0x7F989C (subtracted from the increase request) and the third limit 0x7F8C2E.
- Log 0x0B5 and the DDE torque messages (0x0A8-0x0AA) during downshifts on a 745d to see `ST_TORQ_TAR_EGS` = 1 and the resulting torque.
- Obtain decrypted GS19.11 code or a ZF/BMW label list to name the transmission-side blip parameters (see below).

## Transmission side: GS19.11 calibration (M67D44)

The 6HP26 of the 745d uses GS19.11 (`data/GKE191`, diagnostic SGBD `GS19B`). `GKE191.ATS` assigns type code **HM61** to assembly **7524744**, i.e. program **`7556246A`** (approved 31.03.2005, `047G150P461Z`) with data **`A7524745`** ("E65 M67D44 ECE", 03.06.2005, `047G150P461Z1ZD02`). The same program has 19 data files (M57D30 TU2, N62B40/B44/B48, N73B60, N73H60); a newer program `7586761A` (09.11.2007) is only used for three petrol data files. Analysis tool: [`DDE63-RE/tools/egs191.py`](DDE63-RE/tools/egs191.py), output [`DDE63-RE/out/egs191_cal.md`](DDE63-RE/out/egs191_cal.md).

**Program:** the code (0x080000-0x0E5BDF, and 0x060080-0x06FED5) is encrypted as in GS19.04 (about 7.9 bit/byte; instruction statistics at random level). It was not decrypted. The constants at 0x030000-0x03C84F are plain and contain the CAN lists (12-byte entries: ID, `01`, bus, object, direction, length): 0x0B5 is transmitted with **8 bytes** (bus 1, object 0), together with 0x0BA (8) and 0x1A2 (4); the engine messages 0x0A8, 0x0A9, 0x0AA, 0x1D0 are received. This matches the DDE6.3 receive configuration. The 0x0B5 signal packing is not table-driven in the plain constants, so the TX layout can't be confirmed from the transmission side.

**Calibration layout (`A7524745`, 0x060000-0x07FFFF):** reference string, header with range 0x060080-0x07A2FF and ID `DAE47546`, data 0x060080-0x073B6F, and a reference table at 0x07A300 (5315 entries in code order). Entries below 0x073B70 address 3891 data objects; entries at or above 0x07A300 address 334 **pointer arrays** inside the table (parameter sets with 5-24 members, e.g. per shift type). Curves and maps use the Bosch int16 layout as in GS19.04 (570 curves, 221 maps).

**Engine dependence (19 data files):** 1549 objects are the same for all engines, 104 are shared only by the two diesels, 288 by the diesels and some petrol engines, and 1950 differ between the M67D44 and the M57D30 TU2 (1345 of them differ from every other engine).

**Blip parameters: not identified.** Without code or labels no object can be tied to the positive engine intervention. Three approaches did not isolate it:
- Aligning the code-order reference streams of GS19.02 (no positive intervention), GS19.04 and GS19.11: GS19.04 and GS19.11 match well (similarity 0.86), but about half of GS19.04 has no GS19.02 counterpart, so "new in GS19.04" is far too broad.
- Gear- or shift-type axes: gear-dependent data is organised as pointer arrays, not axes; no new 5/10-member arrays with diesel- or M67-specific contents were found.
- Diesel-only objects (104): they include speed limits (0x06272E 4800 vs. 6500 rpm, 0x071ABA/0x071B76 4300 vs. 6000-6800 rpm), and a block at 0x071A54-0x071B7C with several diesel-specific values. One value stands out: **0x071A62 = 2000 for both diesels, 0 for all petrol engines**. 2000 x 0.5 Nm = 1000 Nm is exactly the "no request" default the DDE6.3 expects in `TORQ_TAR_ADJR_POS_EGS`, so this is a plausible candidate for the neutral value of that signal, but it remains a hypothesis.

To go further, a GS19.11 program read from a unit (decrypted code), a ZF/BMW calibration label file, or a CAN log of 0x0B5 during downshifts (to see the requested torques directly) is needed.
