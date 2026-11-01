# BMW M67 DDE5.1 (EDC16C1): Findings from BMW SP-Daten v60.1

Analysis of the E65 740d (M67D39, 190 kW) diesel engine control unit data in [`Shared/SP-Daten/E65`](../Shared/SP-Daten/E65). Unlike the DDE4.1, there is no Bosch function description for EDC16C, so names come from the diagnostic SGBD and from the code itself.

No vehicle (VIN) is available for this generation, so the software was selected from the SP-Daten files alone (see [Software release](#software-release)).

## DDE5.1 system overview

The early E65 M67D39 uses two Bosch EDC16C1 control units in a master/slave arrangement at diagnostic addresses 12h/13h (`kmmData/kmm_HO.txt`: `12/13:DME_DDE:DDE51`). Both units run **the same program and the same calibration**; the role comes from the unit's position or coding, not from the software.

| Role | Folder | Diagnostic SGBD | Flash SGBD (WinKFP) | Flash parameter file |
|---|---|---|---|---|
| Master | [`data/DDE51`](../Shared/SP-Daten/E65/data/DDE51) | `ecu/D51MM670.prg` "DDE 5.1 fuer M67" (113 jobs) | `ecu/31DDE51.PRG` "Spezial SGBD nur fuer Flashen DDE51" (45 jobs) | `sgdat/33DDE51.IPO` |
| Slave | same | `ecu/D51SM670.prg` (113 jobs) | same | same |

The master and slave SGBDs contain identical tables and job lists (10,197 bytes differ inside the job code, most likely the diagnostic address).

`kmmData/kmm_SG.txt` lists the units as `DDE_031_M67__8Z_DDE51_D40` and `DDE_032_M67__8Z_DDE51_D40`.

**Not the M67D39 DDE5.1:** `data/DDE506` with `ecu/D50M57A0.prg` is the M57TUE (EDC16C1); `data/DDE626` is the M57TUE2 and `data/DDE63` with `ecu/D63MM670.prg` / `D63SM670.prg` the M67TUE (M67D44, 220/242 kW), both on Bosch **EDC16CP35**, i.e. still the EDC16 family.

### File types in `data/DDE51`

| File | Content |
|---|---|
| `.ATS` | Vehicle assignment (here: header only, no entries) |
| `.DAT` | Assembly specification: assembly number, type, hardware and software numbers, index, variant flag |
| `.HIS` | Assembly history: upgrade path old → new assembly number |
| `.HWH` | Hardware history: hardware numbers with index letter |
| `*.0pa` | Program flash image (Intel HEX with BMW-Steyr release header) |
| `V*.0da` | Data/calibration flash image (Intel HEX) |

## Vehicle assignment

`DDE51.ATS` (31.01.2008, TAIS query from 29.11.2007) contains only the column header `FZG;LA;SA;ZB_NR;SE_VS` and no vehicle entries. There is no type-code-to-assembly mapping in this SP-Daten version; the assembly has to be chosen from the `.DAT` file and the variant text in the data file headers.

## Software release

`DDE51.DAT` (31.01.2008) lists one program with two data variants:

| Assembly number | Type number | Hardware number / index | Software number | Variant flag | Data file | Variant text (`K_V2`) |
|---|---|---|---|---|---|---|
| **7810911** | 7789880 | 7809330 / A | 7810913DA | H | `V7810913.0da` | `VQK.1 E65-08-03-470 SA984 EU3` |
| **7810910** | 7789880 | 7809330 / A | 7810912DA | B | `V7810912.0da` | `VQK.1 E65-08-03-470 (ECE) EU3` |

The H/B flag marks two calibration variants (special equipment `SA984` vs. ECE), not master and slave.

### Release details

| | Program | Data variant H | Data variant B |
|---|---|---|---|
| File | `7809330A.0pa` | `V7810913.0da` | `V7810912.0da` |
| BMW reference | `0089EI0AQK1B S` | `0089EI0AQK1BEY220 4` | `0089EI0AQK1BEY200 2` |
| File checksum (`$CHECKSUMME`) | 9389 | CD06 | B5E2 |
| Bosch software number (at 0x8E0054) | | 1037390909 | 1037390909 |
| Approval date | 17.12.2007 | 17.12.2007 | 17.12.2007 |

All headers read `ZL_System: EDC16C1`, `ZL_Projekt: M67D/E65`, `K_F1 E65`, `K_F2 AT`, `K_F3 190 kW`, `K_V1 M67D`.

The two data variants differ in only two calibration bytes:

| Address | V7810913 (H, SA984) | V7810912 (B, ECE) |
|---|---|---|
| 0x8F682A | 0x32 | 0x30 |
| 0x8F6F12 | 0x32 | 0x64 |

Apart from that, only the reference string (0x8E0010), the 64-byte signature (0x8DFF04) and the checksums (0x8FFB76, 0x8FFBF8) differ.

### Flash memory layout

The EDC16C1 uses a Freescale MPC5xx (PowerPC) with 448 KB internal flash and external flash from 0x800000.

| Area | Content |
|---|---|
| 0x000000-0x007FFF | Internal boot area, **not in the update file** |
| 0x008000-0x06FFFF | Program, internal flash (`.0pa`) |
| 0x800000-0x81FFFF | External flash, **not in the update file** (boot/operating system; called by the program) |
| 0x820000-0x87FFFF | Program, external flash (`.0pa`; header `5A5A5A5A 33333333` at 0x820000) |
| 0x8DFE00-0x8FFBFF | Calibration (`.0da`) |

The `.0pa` covers 818,944 bytes, each `.0da` 130,240 bytes. The program header at 0x820180 lists the ranges the program owns (0x8000-0x6FFFF, 0x820000-0x83FFFB, 0x840000-0x87FFFF); a second list at 0x8201C4 has 0x8000-0x6FFFF, 0x8DFE00-0x8DFE3F, 0x8DFF80-0x8FFDFB and 0x840000-0x87FFFF, i.e. it includes the calibration.

### Upgrade history

**Assembly history (`DDE51.HIS`, four chains):**
- 7791581 → 7791287 → 7791684 → 7792115 → 7792170 → 7792934 → 7792993 → 7793082 → 7793325 → 7793532 → 7794367 → 7795087 → **7810910** (variant B)
- 7791289 → 7791686 → 7792117 → 7792172 → 7792936 → 7792995 → 7793084 → 7793327 → 7793534 → 7794369 → 7795089 → **7810911** (variant H)
- 7788816 → 7790444 → 7790679 → 7790691 → 7790735 → 7790889 → 7790973 → 7791083 → 7791175 → 7791244 → 7791412
- 7791246 → 7791414 → 7791583

The last two chains end without a link to the current assemblies, so units on them may need a hardware change to take the 7809330A software.

**Hardware history (`DDE51.HWH`):**
- 7790884A, 7790968A
- 7791164A, 7791253I, 7791572K, 7791227J, 7791616K, 7792107L, 7793026M (E), 7793086N, 7793519A, 7794059A, 7794905A, **7809330A** (F)
- 7790641A, 7790734E

## Checking the actual car

Without a VIN, read the units before relying on the table above. Run these jobs in Tool32 or INPA on `D51MM670` (master) and `D51SM670` (slave):

- `IDENT`: hardware number, index, software number
- `AIF_LESEN`: assembly number last programmed

Expected for the current release: hardware **7809330A** on both units, assembly **7810911** (variant H) or **7810910** (variant B). The flash SGBD `31DDE51.PRG` also offers `AIF_LESEN`, `HARDWARE_REFERENZ_LESEN` and `DATEN_REFERENZ_LESEN`.

## Bosch labels in the diagnostic SGBD

There is no EDC16C function description, but the SGBD carries the Bosch software labels directly. `D51MM670_MESSWERTETAB` has 220 measurement IDs (all `unsigned int`, read with `2C 10 <ID>`), each with its Bosch label (209 distinct), unit and scaling; `BETRIEBSWTAB` lists 222 values with English or German descriptions.

| Module prefix | Labels | Meaning (Bosch EDC16 naming) |
|---|---|---|
| `PFlt`, `PFltCD` | 29 | Particulate filter (soot mass, ash, pressure, temperatures) |
| `InjCrv`, `InjCtl`, `InjVlv`, `InjVCD` | 36 | Injection timing/quantity per pulse, injector energising times, per-cylinder speed |
| `DSM`, `DSMDur` | 17 | Diagnostic system manager (readiness, defect counters) |
| `CrCtl`, `CrCCD` | 13 | Cruise control |
| `AFSCD`, `AirCtl` | 13 | Air-mass meter, air-mass control (EGR) |
| `CoEng`, `CoVM`, `EngM`, `FMTC`, `ASDdc`, `AccPed` | 13 | Torque structure: engine/vehicle-motion coordinators, friction torque, torque-to-quantity conversion, anti-jerk, driver demand |
| `APPCD`, `BPSCD`, `CTSCD`, `IATSCD`, `FTSCD`, `OTSCD`, `VSSCD`, ... | ~30 | Sensor signal conditioning (pedal, boost, coolant, intake air, fuel, oil, vehicle speed) |
| `Rail`, `RailCD`, `MeUn`, `MeUnCD`, `PCVCD` | 10 | Rail pressure control, metering unit, pressure control valve |
| `Gearbx`, `ConvCD` | 3 | Gearbox type and calculated gear, clutch signal |
| Others | | `LIGov` idle governor, `StSys` start, `GlwCtl` glow, `ACCtl` A/C, `FrmMng` frame manager, `HWEMon` hardware monitoring, ... |

Gearbox-related CAN messages named in the fault texts (`FORTTEXTE`): `TORQUE_GEARBX` 0x0B5 (4DF0-4DF3), `GEARBX_DATA` 0x0BA (4BE2/4BE3), `GEARBX_DATA2` 0x1A2 (4BE7/4BE8), `TORQUE_DSC` 0x0B6 (4C20-4C23), `DREHMOMENT_ANF_ACC` 0x0B7 (45F5-45F8).

### Flash SGBD `31DDE51.PRG` (45 jobs)

INFO, FLASH_PARAMETER_LESEN, FLASH_PARAMETER_SETZEN, DIAGNOSE_MODE, FS_LOESCHEN, DIAGNOSE_AUFRECHT, DIAGNOSE_ENDE, AIF_LESEN, SERIENNUMMER_LESEN, ZIF_LESEN, ZIF_BACKUP_LESEN, HARDWARE_REFERENZ_LESEN, DATEN_REFERENZ_LESEN, DIAGNOSEPROTOKOLL_LESEN, DIAGNOSEPROTOKOLL_SETZEN, FLASH_ZEITEN_LESEN, FLASH_BLOCKLAENGE_LESEN, NORMALER_DATENVERKEHR, AUTHENTISIERUNG_ZUFALLSZAHL_LESEN, AUTHENTISIERUNG_START, FLASH_SIGNATUR_PRUEFEN, FLASH_PROGRAMMIER_STATUS_LESEN, STEUERGERAETE_RESET, FLASH_LOESCHEN, FLASH_SCHREIBEN_ADRESSE, FLASH_SCHREIBEN, FLASH_SCHREIBEN_ENDE, AIF_SCHREIBEN, ABGLEICHWERTE_LESEN, ABGLEICHWERTE_SCHREIBEN, MARK_LO1, MARK_LO2, MARK_LO3, TEL_ROH, AGR_NULL, INITIALISIERUNG, IDENT, PHYSIKALISCHE_HW_NR_LESEN, INNENTEMP_LESEN, SET_BAUDRATE, INTERFACETYPE, STEUERN_SYNC_MODE, STATUS_SYNC_MODE, EWS_STARTWERT, EWS_EMPFANG

Compared with the DDE4.1 flash SGBD, programming uses authentication (`AUTHENTISIERUNG_*`) and a signature check (`FLASH_SIGNATUR_PRUEFEN`) instead of `SEED_KEY`; the data files carry a 64-byte signature at 0x8DFF04.

## Method notes

- SGBD (`.prg`) files are EDIABAS objects with every byte XOR'd with `0xF7` (same as DDE4.1).
- The flash images are Intel HEX with `;` comment headers and `$REFERENZ` / `$CHECKSUMME` lines. They combine type 02 (segment) and 04 (linear) address records, and carry the last 16 bytes of each 64 KB block in **type 0x10** records. [`hex2bin.py`](DDE41A-RE/tools/hex2bin.py) handles both.
- Data variant comparison and the memory map come from the converted binaries in [`DDE51-RE/bin`](DDE51-RE/bin).

## Reverse engineering of the DDE5.1 release

[`DDE51-RE/`](DDE51-RE/README.md) contains a static analysis of `7809330A` with data variant `V7810913`, with reproducible Python tools:

- **PowerPC disassembly:** 178,130 instructions, 1815 functions; base registers r2 = 0x0100F0 and r14 = 0x8261AC confirmed from the startup code, r13 assumed (set in the missing boot code).
- **Curves and maps:** interpolation routines at 0x0583BC (curves) and 0x0584B4 (maps); 645 curves/maps extracted (376 KL, 269 KF), 483 of them referenced by lookup calls.
- **Measurement table:** at 0x00A1A4, 523 RAM addresses indexed by SGBD measurement ID. The addressed block is written by code that isn't visible, so labels can't be attached to functions yet.
- **CAN:** message objects, the signal descriptor table (0x896C) and the receive path decoded. `TORQUE_GEARBX` (0x0B5) is decoded in visible code (`fn_02E490`) from receive record 23, which carries the documented 8-byte layout; the gateway forwards bits 0-39 of it to the slave over the private CAN. Record 7 holds an older layout (handles 0x94-0x9E) that is not used. (An earlier version of this document said 0x0B5 is not decoded; that was wrong.)
- **0x0B5 layout:** as documented in [E65_ReverseEngineering](https://github.com/HeinrichG-V12/E65_ReverseEngineering/blob/main/docs/0x0B5.md): checksum bits 0-7, alive counter 8-11, `TORQ_TAR_EGS` 12-23, `TORQ_TAR_ADJR_POS_EGS` 24-35, `ST_TORQ_TAR_EGS` 36-37 (1 = increase, 2 = decrease), `ST_OBD_GRB` 40-43, `ST_LIM_STORQ` 46-47, `TORQ_DRAW_GRB` 48-55, `TEMP_GRB` 56-63. All are read from record 23.
- **Fault path table:** calibration 0x8E4A4C, 4 DTCs per path (0x6B = 4DF0 `TORQUE_GEARBX`). Path 0x6F "4920 Momenteneingriff Getriebe (nv)" is actually the check for 0x19E (DSC status, object 11, `fn_869C54`); the SGBD text is a leftover.
- **Downshift blip:** found, same structure as in the DDE6.3. `ST_TORQ_TAR_EGS` = 1 turns `TORQ_TAR_EGS` into a minimum-torque request (RAM 0x402422). `fn_856C5C` passes it through a ramp switch (permission bit 0x409990, slopes 0x8EAE64, only active on enable/disable) to 0x402452, and the torque coordinator `fn_85D864` applies `min(demand, gear limit)` (`fn_856888`, 700 Nm in every gear), then `max(·, 0x402452)`, then the reduction request (0x85D8BC-0x85D8F8). The per-gear limit therefore caps the driver demand but not the blip. The DDE has no blip amount or duration of its own; they come from the EGS. Details in [`DDE51-RE/README.md`](DDE51-RE/README.md#downshift-blip-positive-engine-intervention).
- **Not available:** 0x000000-0x007FFF and 0x800000-0x81FFFF. Both are external/internal flash, so a bench read of a real unit would contain them.

## Possible next steps

- Read a real DDE5.1 (internal and external flash) to obtain 0x800000-0x81FFFF (operating system; not needed for the torque-request path, which is visible).
- Compare with the DDE6.3 software for the M67D44 (`data/DDE63`, EDC16CP35): done in [M67-DDE63-Findings.md](M67-DDE63-Findings.md). The DDE6.3 decodes 0x0B5 completely and applies the EGS increase request as a minimum torque in its torque coordinator.
- Read `IDENT` / `AIF_LESEN` on the actual car to confirm the release and data variant.
- Analyse the GS19.04 calibration further once labels or decrypted program code are available (see below).

## Cross-check with the transmission (GS19) software

The E65 6HP26 transmission control units are in `data/GKE19x` (diagnostic SGBDs `ecu/GS19.prg` = GS19.02, `GS19A.prg` = GS19.04, `GS19B.prg` = GS19.11). The `EK92x` folders are petrol engine units (ME9/MED9), not transmissions. The M67D39 appears as **M67D40** in the transmission data headers:

| Folder | Platform | Program | Assembly | Data | Data header |
|---|---|---|---|---|---|
| `GKE192` | GS19.02 | `7534928A` | 7537217 | `A7537218` | "Motorvariante M67D40, ECE" |
| `GKE192` | GS19.02 | `7534929A` | 7537233 | `A7537234` | "Motorvariante M67D40, ECE" |
| `GKE194` | GS19.04 (approved 22.03.2005) | `7557063A` | 7559200 | `A7559201` | "E65 M67D40 ECE" |

`GKE191` (GS19.11) has the later M67D44; `GKE211`/`GKE214` are the 6HP19.

The transmission **program code is encrypted** in the exchange files (entropy about 7.95 bit/byte), so its signal packing can't be disassembled. The CAN configuration tables and the calibration files are plain. The tables use the same framework as the DDE5.1 (TouCAN bases 0x307080/0x307480, 24-byte message entries); [`DDE51-RE/tools/egs_can.py`](DDE51-RE/tools/egs_can.py) extracts them and compares them with the DDE list in [`DDE51-RE/out/egs_can.md`](DDE51-RE/out/egs_can.md).

**E65 PT-CAN messages of the transmission:**

| | GS19.02 (`7534929A`, list at 0x15134) | GS19.04 (`7557063A`, list at 0xB4AA4) |
|---|---|---|
| Transmits | 0x0BA (7 bytes), **0x0B5 (8)**, 0x1A2 (2), 0x2FC, 0x3B4, 0x2FA, 0x330, 0x2E4 | 0x0BA (8), **0x0B5 (8)**, 0x1A2 (2), 0x2FC, 0x3B4, 0x2FA, 0x330, 0x2E4, **0x310 (7), 0x315 (2), 0x1B4** |
| Receives | 0x192, 0x0A8, 0x0A9, 0x0AA, 0x1D0, 0x0B6, 0x130, 0x0CE, 0x19E, 0x1A0, 0x374, 0x0AE, 0x190, 0x0B7 | same without 0x190, plus **0x200** and 0x0B5 |

GS19.04 also has a second list (0xB4D14) with the older E38/E53-style messages (0x43F EGS1, 0x153 ASC1, 0x316/0x329 DME1/2, ...), because that software also serves the E53.

**Comparison with the DDE5.1 analysis:**

| Point | Transmission | DDE5.1 | Result |
|---|---|---|---|
| Gearbox message IDs | Transmits 0x0B5, 0x0BA, 0x1A2 | Receive objects 7, 8, 9 | Match |
| Engine messages | Receives 0x0A8, 0x0A9, 0x0AA, 0x1D0 | In the DDE message list | Match |
| `TORQUE_GEARBX` 0x0B5 length | 8 bytes | Receive record 23 with the documented 8-byte layout (record 7: older 5-byte layout, unused) | Match. The master forwards bits 0-39 (checksum, alive, both torque targets, status) to the slave |
| `GEARBX_DATA2` 0x1A2 length | 2 bytes (both versions) | Object length 7; signals 0x4B (bits 0-11) and 0x4C (bits 28-39) | **Difference**: only 0x4B can come from this transmission; 0x4C is for another transmission variant |
| `GEARBX_DATA` 0x0BA length | 7 (GS19.02) / 8 (GS19.04) | 8; signals use bits 0-9 only | No effect |
| Network generation | GS19.04 adds 0x310, 0x315, 0x1B4 (transmit) and 0x200 (receive) | DDE list contains 0x310, 0x1B4 and 0x200 | DDE5.1 `7809330A` matches the GS19.04 network |

**Positive engine intervention (downshift blip).** The GS19.04 and GS19.11 SGBDs contain faults for a *positive* engine intervention, i.e. a torque increase requested by the transmission: `4F77` "Fehlerhafter Positiver Motoreingriff", `0x00A5` "pos. Motoreingriff fehlerhaft (ZF)" and `0x00A7` "Überwachungsebene2-Berechnung pos. Motoreingriff". The GS19.02 SGBD has none of these, only `51A5` "CAN Momentenschnittstelle". All three record the environment value "Sollmoment fuer Motoreingriff" (Nm). So the torque increase on downshifts is requested by the transmission through 0x0B5 from GS19.04 on; the DDE5.1 decodes it and applies it as a minimum torque (see above). The target is `TORQ_TAR_EGS` (bits 12-23, 0.5 Nm) with `ST_TORQ_TAR_EGS` = 1 ("increase torque"). To see it on the car, log 0x0B5 on PT-CAN during a kick-down or manual downshift.

### GS19.04 calibration (`A7559201`, M67D40)

[`DDE51-RE/tools/egs_cal.py`](DDE51-RE/tools/egs_cal.py) decodes the calibration and compares it with the other engine variants of the same program `7557063A` (M57D30 TU `A7559199`/`A7577366`, N62B36 `A7559189`, N62B44 `A7559191`, N73B60 `A7559203`); output in [`DDE51-RE/out/egs_cal.md`](DDE51-RE/out/egs_cal.md).

- **Layout:** the data (file 0xE0000-0xFFFFF) is mapped at 0x6E0000. A pointer table at 0xE0080 holds 4843 references (in code order, with repeats) to 3816 objects, ending with the string `DAE22036`. Curves and maps use the same int16 layout as Bosch (`n, x[n], y[n]` / `nx, ny, x, y, z`); many other objects are 8-bit scalars and arrays.
- **Engine dependence:** 1738 objects are the same for all engines, 245 are shared by the two diesels only, and 1833 are specific to the M67 (95 KB of the 129 KB). Most of the shift calibration is tuned per engine.
- **Decoded tables:** 154 + 19 + 385 curves and 10 + 9 + 191 maps (generic / diesel / M67). Recognisable families: 29 shift-line maps (8x10, x 31-156, y 22-184); 20 maps over engine speed (750-5000 rpm) x engine torque (-100..900 Nm) at 0x6E9AC0-0x6EA018, two identical sets of 10, with values rising with torque (e.g. 0x6E9BE0: 50 -> 1250), typical of clutch-pressure maps; 8 maps at 0x6EA060-0x6EA210 over a signed axis (-1000..2000) x torque (-102..450 Nm). In the M67 data, 0x6EA0F0 and 0x6EA138 depend only on torque (0 up to about 100 Nm, then 100-300), while the other engines have flat values of 250-550.
- **Blip parameters: not identified.** The calibration has no labels and the program code is encrypted, so no table can be tied to the positive engine intervention with confidence. A decrypted GS19.04 program (from a unit read) or a ZF/BMW label file would be needed.
