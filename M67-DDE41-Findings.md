# BMW M67 DDE4.1 (EDC15C): Findings from BMW SP-Daten v60.1

Analysis of the E38 740d (M67D39) diesel engine control unit data in [`Shared/SP-Daten/E38`](../Shared/SP-Daten/E38), cross-referenced with the Bosch EDC15C function description in [`EDC15C-Function-Description`](../Shared/Documentation/EDC15C-Function-Description/README.md).

## Reference vehicle

| Item | Value |
|---|---|
| VIN | WBAGE81080xxxxxxx |
| Type code (VIN chars 4-7) | **GE81** = E38 740d, M67D39 V8 diesel |
| Production date | 2001-07-26 |
| Applicable DDE release | **O release** (assembly numbers 7787645 / 7787647) |

## DDE4.1 system overview

The M67 uses two Bosch EDC15C control units in a master/slave arrangement. This matches the DDE4.1 variant in the function description (K-Line addresses 12h/13h, 8 cylinders, firing order 1-5-4-8-6-3-7-2).

- **Master (DDE41A):** runs the whole engine, including CAN, torque handling, vehicle-speed control and the A/C interface.
- **Slave (DDE41B):** runs its own cylinder bank and reports per-cylinder speed.

| Role | Folder | Diagnostic SGBD | Flash SGBD (WinKFP) | Flash parameter file |
|---|---|---|---|---|
| Master | [`data/DDE41A`](../Shared/SP-Daten/E38/data/DDE41A) | `ecu/DDE41KR0.prg` "DDE 4.1 fuer M67 Master" (232 jobs) | `ecu/12DDE41A.prg` (35 jobs) | `sgdat/10DDE41A.ipo` |
| Slave | [`data/DDE41B`](../Shared/SP-Daten/E38/data/DDE41B) | `ecu/DDE41KL0.prg` "DDE 4.1 fuer M67 Slave" (157 jobs) | `ecu/12DDE41B.prg` | `sgdat/10DDE41B.ipo` |

`kmmData/kmm_SIT.txt` also names `dde41kr0` at address 12.

**Not for the E38:** `ecu/D51MM670.prg`, `D51SM670.prg`, `D63MM670.prg` and `D63SM670.prg` belong to later M67 control units (DDE5.x/6.x), not the E38's EDC15C.

### File types in `data/DDE41x`

| File | Content |
|---|---|
| `.ATS` | Vehicle assignment: type code → assembly number |
| `.DAT` | Assembly specification: assembly number, type, hardware and software numbers, index |
| `.HIS` | Assembly history: upgrade path old → new assembly number |
| `.HWH` | Hardware history: hardware numbers with index letter |
| `*.0PA` | Program flash image (Intel HEX with BMW-Steyr release header) |
| `Y*.0DA` | Data/calibration flash image (Intel HEX) |

## Vehicle assignment (GE81)

GE81 has exactly one entry in each assignment file:

| File | Type | Assembly number |
|---|---|---|
| `DDE41A.ATS` (01.09.2000) | GE81 | **7787645** |
| `DDE41B.ATS` (06.09.2000) | GE81 | **7787647** |

## Software releases

| Release | Power | Master program / data | Slave program / data | Approval |
|---|---|---|---|---|
| **K** | 175 kW, AT | `7785953K.0PA` / `Y7786148.0DA` | `7785954K.0PA` / `Y7786150.0DA` | May 1999 |
| **O** (current) | 180 kW, AT | `7787316O.0PA` / `Y7787646.0DA` | `7787317O.0PA` / `Y7787648.0DA` | Aug/Sep 2000 |

### O release details (applies to the reference vehicle)

| | Master (DDE41A) | Slave (DDE41B) |
|---|---|---|
| Assembly number | 7787645 | 7787647 |
| Type number | 7786594 | 7786595 |
| Hardware number / index | 7787316 / O | 7787317 / O |
| Software number | 7787646DA | 7787648DA |
| Program file | `7787316O.0PA` | `7787317O.0PA` |
| Data file | `Y7787646.0DA` | `Y7787648.0DA` |
| Bosch software ID (at 0x90022) | `CC1100114455` | `CC0099884455` |
| BMW reference | `000101004500 C` | `000098004500 9` |
| Bosch hardware number (at 0xFBFB0) | 1037351475 | 1037351476 |
| File checksum (`$CHECKSUMME`) | program 3A0F, data F1B3 | program B940, data 114D |

The O release header reads `ZL_System: EDC15C4`, `ZL_Projekt: M67D/E38`, `K_F1 E38`, `K_F2 AT`, `K_F3 180 kW`.

### Flash memory layout

| Area | K release | O release |
|---|---|---|
| Program (`.0PA`) | 256 KB: 0x80000-0xBFFDF plus small blocks at 0xDFF00 and 0xEFF00 | 448 KB: 0x80000-0xEFFDF |
| Data (`.0DA`) | 48 KB: 0xF0000-0xFBFDF | 48 KB: 0xF0000-0xFBFDF |

The program images contain an identification block at 0xDFF70 (BMW reference repeated 3 times, then the hardware number 6 times). The slave images also contain the marker `B098EWS…`.

### Upgrade history

**Master (`DDE41A.HIS`):**
- Path 1: 7785037 → 7781427 → 7785529 → 7785619 → 7785844 → 7785955 → **7786147** (K hardware)
- Path 2: 7786315 → 7786824 → 7787033 → **7787645** (L/M/O hardware)

**Slave (`DDE41B.HIS`):**
- Path 1: 7785039 → 7781429 → 7785531 → 7785621 → 7785846 → 7785957 → **7786149** (K hardware)
- Path 2: 7786317 → 7786826 → 7787035 → 7787134 → **7787647** (L/M/O hardware)

**Hardware history (`.HWH`):**
- Master: 7785118B, 7785542C, 7785953K, 7786313L, 7786822M, 7787316O
- Slave: 7780014A, 7785119B, 7785543C, 7785843D, 7785954K, 7786314L, 7786823M, 7787133M, 7787317O

An ECU with K-index hardware (7785953K / 7785954K) is on path 1. It ends at 7786147 / 7786149 and can't take O software.

## Checking the actual car

The ECUs may have been replaced or reflashed since 2001, so check them before relying on the table above. Run these jobs in Tool32 or INPA on both SGBDs (`DDE41KR0` and `DDE41KL0`):

- `IDENT`: hardware number, index, software number
- `AIF_LESEN`: assembly number last programmed

Expected: **7787645 / 7787316O** (master) and **7787647 / 7787317O** (slave).

## Link to the EDC15C function description

The function description is Bosch Y 445 S00 003-CC0 (B079.CC0, January 2001). The flash images use Bosch software IDs from the same `CC…` series. The exact variant can't be confirmed without the original PDF.

Most diagnostic `STATUS_*` jobs are named after EDC15C software variables, for example `STATUS_ANMWTF` → `anmWTF` and `STATUS_MRMM_EAKT` → `mrmM_EAKT`. **148 of the 196** unique variable names in the master and slave SGBDs appear word-for-word in [`en/`](../Shared/Documentation/EDC15C-Function-Description/en/00-Table-of-Contents.md).

The other 48 are mostly:
- **Bank-numbered (1/2) versions** of documented variables, needed for the M67's two air-mass meters, boost actuators and EGR actuators: `anmLMM1/2`, `anmLTF1/2`, `anmLDF1`, `admLMM1/2`, `ehmFARS1/2`, `ehmFLDS1/2`, `ehmFGRS2`, `ehmFMML1`, `aroIST_51/52`, `armM_LIST1/2`.
- **Plain-language jobs:** `STATUS_RAILDRUCK`, `STATUS_LADEDRUCK`, `STATUS_MOTORDREHZAHL`, `STATUS_MOTORTEMPERATUR`, `STATUS_GASPEDAL`, `STATUS_LMM_MASSE`, `STATUS_VORFOERDERDRUCK`, `STATUS_PWG_FAHRERWUNSCH`, `STATUS_PWG_POTI_SPANNUNG`.
- **Others:** `anmIZE`/`admIZE`, `aroLMX`, `aroREGSTAT`, `ehmFZME`, `zumAD_NE2`, `STATUS_DIGITAL1-3`, `STATUS_LAUFUNRUHE_*`, `STATUS_SYNC_MODE`.

### Job groups and matching chapters

| SGBD job group | Purpose | Chapter |
|---|---|---|
| `STATUS_ANM*`, `STATUS_ADM*`, `STATUS_ANOU_*`, `STATUS_DZM*` | Sensor values, raw ADC values, speed | [02 Signal Preprocessing](../Shared/Documentation/EDC15C-Function-Description/en/02-Signal-Preprocessing.md) |
| `STATUS_MRM*`, `STATUS_MRO*`, `ABGLEICH_*_MENGE`, `*_LL_REGELUNG`, `*_MENGENDRIFT` | Fuel quantity, torque, idle control, adjustment values | [03 Fuel Quantity Control](../Shared/Documentation/EDC15C-Function-Description/en/03-Fuel-Quantity-Control.md) |
| `STATUS_ZUMP_RAIL`, `STATUS_ZUMPQSOLL`, `STEUERN_KS_HDPUMPE_ABSCHALTUNG` | Rail pressure, high-pressure pump | [04 High Pressure Control](../Shared/Documentation/EDC15C-Function-Description/en/04-High-Pressure-Control.md) |
| `STATUS_ARO*`, `STATUS_ARMM_*`, `STEUERN_AGR_STELLER1/2`, `ABGLEICH_*_AGR_RUECK` | EGR | [05 Exhaust Gas Recirculation](../Shared/Documentation/EDC15C-Function-Description/en/05-Exhaust-Gas-Recirculation.md) |
| `STATUS_LDM*`, `STATUS_LDO*`, `STEUERN_LADEDRUCKSTELLER1/2` | Boost pressure | [06 Boost Pressure Control](../Shared/Documentation/EDC15C-Function-Description/en/06-Boost-Pressure-Control.md) |
| `STEUERN_EKP`, `STEUERN_GLUEHRELAIS1/2`, `STEUERN_E_LUEFTER`, `STEUERN_KLIMAKOMPRESSOR`, `STEUERN_ZUHEIZER`, `STEUERN_MOTORLAGER`, `STATUS_EHM*` | Auxiliary functions and actuators | [07 Auxiliary Functions](../Shared/Documentation/EDC15C-Function-Description/en/07-Auxiliary-Functions.md) |
| `START_SYSTEMCHECK_ZYL_SEL_*`, `STATUS_LAUFUNRUHE_*`, `STATUS_DZMZN1-8` | Cylinder smoothness and speed test | [03 Fuel Quantity Control](../Shared/Documentation/EDC15C-Function-Description/en/03-Fuel-Quantity-Control.md) |
| `STATUS_CA*`, `STATUS_COMGTR_OPT`, `STATUS_GSO*` | CAN messages, gearbox | [09 CAN Functions](../Shared/Documentation/EDC15C-Function-Description/en/09-CAN-Functions.md) |
| `STATUS_SYNC_MODE`, `STEUERN_SYNC_MODE`, `WECHSELCODE_SYNC_DME`, `SEED_KEY`, `TEL_ROH` | K-Line communication, immobiliser sync | [10 External Communication K-Line](../Shared/Documentation/EDC15C-Function-Description/en/10-External-Communication-K-Line.md) |
| `FS_*` (with `_SL` versions for the slave), `STATUS_FBM*`, `STATUS_FBO*` | Fault memory | [A Fault Handling](../Shared/Documentation/EDC15C-Function-Description/en/A-Fault-Handling.md) |
| `12DDE41A.prg`: `FLASH_*`, `UPROG_*`, `AIF_*`, `BAUDRATEN_*` | Reprogramming | [B Reprogramming Guide](../Shared/Documentation/EDC15C-Function-Description/en/B-Reprogramming-Guide.md) |

### Master vs. slave SGBD

- **Master only:** CAN messages (`STATUS_CA*`), driver demand and torque (`STATUS_MROMD_*`, `STATUS_MRMPWGFI`), start and limit quantity adjustment, vehicle-speed control and A/C adjustment (`ABGLEICH_*_FGR_*`), fuel consumption correction, most actuator tests (fuel pump, glow relays, boost actuators, A/C compressor, electric fan, engine mounts, auxiliary heater), slave fault memory access (`FS_*_SL`).
- **Slave only:** per-cylinder speed and segment values (`STATUS_DZMZN1-8`, `STATUS_DZMZMK1-8`), injection/timing outputs (`STATUS_ZUO*`), rail pressure (`STATUS_RAILDRUCK`).
- **Both:** EGR actuators, high-pressure pump shut-off, idle/full-load/adjustment quantity, quantity drift, cylinder smoothness test.

### Flash SGBD `12DDE41A.prg` (35 jobs)

INITIALISIERUNG, INFO, UPROG_EIN, UPROG_AUS, BLOCKLAENGE_MAX, DATEN_REFERENZ, HW_REFERENZ, ZIF, ZIF_BACKUP, AIF_LESEN, IDENT_AIF, ECU_CONFIG, GET_CURRAIFADR, AIF_SCHREIBEN, FLASH_LESEN, START_DIAGNOSTIC_SESSION, STATUS_LESEN, FLASH_LOESCHEN, FLASH_SCHREIBEN_ADRESSE, FLASH_SCHREIBEN, FLASH_SCHREIBEN_ENDE, SEED_KEY, IDENT, FS_LOESCHEN, STATUS_CODIER_CHECKSUMME, DIAGNOSE_ENDE, STEUERN_SYNC_MODE, WECHSELCODE_SYNC_DME, STATUS_SYNC_MODE, TEL_ROH, BAUDRATEN_UMSTELLUNG, BAUDRATEN_LESEN, SET_EDIC_BAUDRATE, UPROG_LESEN, ADAPTION_LOESCHEN

## Method notes

- SGBD (`.prg`) files are EDIABAS objects with every byte XOR'd with `0xF7`. The job table offset is at file offset 0x88, and the info block offset is at 0x90.
- Flash images are Intel HEX files (record types 00/02/04) with `;` comment headers and `$REFERENZ` / `$CHECKSUMME` lines.
- The variable cross-reference compares `STATUS_<name>` job suffixes, case-insensitively and as whole words, against the English chapters of the function description.

## Possible next steps

- Map every diagnostic job to its variable and document section for the O release.
- Add a downshift blip (quantity-increasing transmission intervention) for the 8HP/CANTCU conversion: design in [Blip-Function.md](Blip-Function.md).

## Reverse engineering of the DDE41A O release

[`DDE41A-RE/`](DDE41A-RE/README.md) contains a static analysis of the master program and data (`7787316O` / `Y7787646`), with reproducible Python tools:

- **C167 disassembly:** 47,790 instructions, 638 functions, annotated with RAM variable names and calibration labels.
- **Measurement table:** at 0x091000, linking all 127 SGBD measurement IDs to RAM addresses.
- **Label pointer table:** at 0xF1000, 783 calibration labels.
- **Curves and maps:** 87 curves and 55 maps decoded, with axes, values and the functions that use them. Driver demand, start quantity, smoke limitation, boost setpoint, EGR setpoint, MAF linearisation and glow maps are identified.
- **Not available:** the segment-0 code (scheduler, interpolators, fault manager). A full read of the external flash (`0281010843` / `1037351475`) is identical to the O release and doesn't contain it, so it's most likely the C167's internal 32 KB ROM.
- **Top flash sector** (0xFC000-0xFFFFF, only in the full flash read): flash erase/program drivers that run from RAM, a checksum routine, and the reprogramming layer (K-line, KWP2000, security access). Its memory-read handler also rejects segment 0, so the ROM can't be read over the diagnostic line.

## Reverse engineering of the DDE41B O release (slave)

[`DDE41B-RE/`](DDE41B-RE/README.md) applies the same tools to the slave (`7787317O` / `Y7787648`, SGBD `DDE41KL0`):

- **Code:** 28,919 instructions, 496 functions.
- **Measurement table:** at 0x090800, linking all 99 slave SGBD measurement IDs to RAM addresses.
- **Calibration:** 539 labels, 50 curves and 14 maps (10 of the maps are constant, i.e. unused on the slave).
- **What the slave computes:** injection timing and duration (energising-time maps 0xF3216/0xF367E), rail pressure control (0xF2ED2), smooth-running and idle control, per-cylinder speed, and its own sensors (rail pressure, boost 1, air mass 1, intake air 1).
- **CAN:** it isn't on the vehicle CAN. Its on-chip CAN carries only the private master/slave link (CANP), over which the master sends processed values such as `mrmM_EWUN` (the quantity after the transmission/ASC interventions). The slave returns engine speed (the master's `dzmNmit`), the quantities after surge damping and idle control, rail pressure and setpoint, its sensors and its diagnostic-lamp request; a crank-synchronous frame 0x008 lets the master check that both banks are in step. The master consumes EGS1 itself and doesn't forward vehicle messages; see [`DDE41A-RE`](DDE41A-RE/README.md#canp-protocol).
