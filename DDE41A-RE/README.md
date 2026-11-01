# DDE41A (M67 master ECU), O release: reverse engineering

Static analysis of the BMW E38 740d (M67D39) **master** DDE4.1 control unit, Bosch EDC15C, software release **O**:

| | |
|---|---|
| Program | [`7787316O.0PA`](../../Shared/SP-Daten/E38/data/DDE41A/7787316O.0PA), 0x80000-0xEFFFF (content only in 0x90000-0xBFFFF) |
| Data | [`Y7787646.0DA`](../../Shared/SP-Daten/E38/data/DDE41A/Y7787646.0DA), 0xF0000-0xFBFFF |
| Assembly / Bosch IDs | 7787645, `CC1100114455`, Bosch HW 1037351475 |
| Diagnostic SGBD | [`DDE41KR0.prg`](../../Shared/SP-Daten/E38/ecu/DDE41KR0.prg) ("DDE 4.1 fuer M67 Master") |
| CPU | Infineon C167 (16-bit, segmented, DPP data paging) |

See [`../M67-DDE41-Findings.md`](../M67-DDE41-Findings.md) for how this release was selected for the reference vehicle (VIN WBAGE81080xxxxxxx, built 2001-07-26).

## Results at a glance

| Item | Result |
|---|---|
| Code decoded | 47,790 instructions / 158 KB (≈ 90% of the 177 KB program content) |
| Functions | 638 (call targets plus code blocks that follow returns) |
| Segment-0 (ROM) services | 50 called (internal ROM, **not in flash**) |
| Measurement table | 260 measurement IDs → RAM addresses; all 127 SGBD IDs resolved |
| Calibration labels | 783 labels via the pointer table at 0xF1000 |
| Curves / maps | 87 curves (KL) + 55 maps (KF); 141 of 142 linked to code |
| Fault reports | 492 call sites on 31 fault paths |
| Fault codes | 460 of the 492 reports (those with a debounce label) assigned to the SGBD fault code they set, via 54 fault-code descriptor labels; 217 fault indices, none ambiguous (see [Fault paths](#fault-paths)) |
| Diagnostics (EDIABAS) | All 142 `STATUS_*` jobs of `DDE41KR0.prg` run with the original job code in the EdiabasLib simulator: telegrams, byte layout and scaling measured, 139 jobs joined to RAM variables (see [Diagnostic protocol (EDIABAS / INPA)](#diagnostic-protocol-ediabas--inpa)) |
| INPA | Screens of `DDE41R.IPO` / `10DDE41A.ipo` recovered; two menu items call a job that doesn't exist in the SGBD |

## Memory map

| Address | Content |
|---|---|
| 0x0000-0x7FFF (segment 0) | Most likely C167 internal 32 KB ROM: scheduler, interpolation, fault manager (`CALLS 0:xxxx`). Not in any flash file or flash read |
| 0x80000-0x8FFFF | Unused (`C3` filler, 0x88000-0x8FFFF zeros in the flash read) |
| 0x90000 | Bosch ID block: `CC1100114455`... |
| 0x90082 | `init_from_boot`: sets DPP0/DPP1, calls bus and port init, `EINIT` |
| 0x91000 | Measurement table: `55AA`, count 0x0104, 260 sorted IDs, then 260 RAM addresses |
| 0x92000 | Jump table (`55AA` + `JMPS`) into application entry points and boot services |
| 0x90000-0xBFFFF | Application code and constant tables |
| 0xC0000-0xEFFFF | Empty, apart from the identification block at 0xDFF00 (reference, HW number) |
| 0xF0000-0xF01FF | Data-area header, interrupt redirect table (`JMPS` stubs) |
| 0xF1000-0xF161D | **Label pointer table**: 783 16-bit pointers (DPP0/DPP1 form) |
| 0xF161E-0xF7845 | Calibration labels (scalars, arrays, curves, maps) |
| 0xFBC00-0xFBFDF | Data identification: reference strings at 0xFBC98, Bosch HW number at 0xFBFB0 |
| 0xFC000-0xFFFFF | Top sector, only in the flash read: RAM-loaded flash-programming blocks and ID area (see below) |
| 0xC000-0xFFFF (DPP3) | Internal/external RAM and SFRs |
| 0xB000 (segment 0) | External Intel 82527 CAN controller (`ADDRSEL2 = 0x00B0`, initialised at 0x09664E): private master/slave CAN (CANP), see [CAN controllers and master/slave link](#can-controllers-and-masterslave-link) |
| 0xEF00-0xEFFF | C167 on-chip CAN module (initialised at 0x097B28): vehicle/transmission CAN |

The data page pointers after init are DPP0 = 0x3C (0xF0000), DPP1 = 0x3D (0xF4000) and DPP3 = 3. DPP2 is switched at run time (e.g. 0x02, 0x24 = 0x90000, 0x3E = 0xF8000). So a 16-bit operand 0x0000-0x7FFF addresses calibration data at 0xF0000-0xF7FFF. Rail pressure is stored at 0.1 bar/bit (axis 1190-14500 = 119-1450 bar).

## How the firmware is organised

### Scheduler and segment-0 (ROM) services

The application doesn't contain the operating system. Tasks start with a 12-byte stub (`POP CC11 / MOV 0xDBE0,CC11 / BCLR PSW.11 / JMPS 0:0830`), and the segment-0 (ROM) scheduler dispatches them. Services identified from their call sites:

| Boot address | Name used | Evidence |
|---|---|---|
| 0:0CB2 | `boot_KL_interp` | 66 calls; `R12` = curve descriptor, `R13` = input value; result in `R4` |
| 0:0CDC | `boot_KF_interp` | 70 calls; `R12` = map descriptor, `R13`/`R14` = input values; result in `R4` |
| 0:2000 | `boot_fault_report` | Reached via 0x092006, 492 calls; see fault paths below |
| 0:0830 | `boot_task_prologue` | Start stub of scheduled tasks |
| 0:02D6 | `boot_fatal_reset` | Interrupts disabled, `MDL` = error code (e.g. 0x25 after a failed range check) |

Every curve/map descriptor passed to the two interpolators (65 + 67 call sites) is in the extracted map list.

### Calibration labels

All calibration data is reached through the **label pointer table** at 0xF1000. Code loads a pointer (`MOV R12, 0x121A`) and passes it to an interpolator, or reads parameters through it. This links every label to the functions that use it ([`out/labels.csv`](out/labels.csv)).

Curve and map format, verified against the code (e.g. at 0x09D3C8 the input is written to 0xDCBA, and the curve passed has 0xDCBA as its header):

```text
curve KL : [input RAM address][n][x1..xn][v1..vn]
map   KF : [x input RAM address][nx][x1..xnx][y input RAM address][ny][y1..yny][values, y fastest]
```

The value order (y fastest) was confirmed by smoothness on all 44 maps with at least 4×4 points. The header input address is the canonical variable a calibration tool would show. At run time the code passes the values in `R13`/`R14`, often after copying them to the scratch area at 0xC4xx.

### Measurement table and named variables

The table at 0x091000 is what the SGBD's `BETRIEBSWTAB` IDs (`ADR` column) refer to. Joining both gives named RAM variables ([`out/measurement_table.csv`](out/measurement_table.csv)), for example:

| Variable | RAM | | Variable | RAM |
|---|---|---|---|---|
| `dzmNmit` engine speed | 0xC0A8 | | `ldmP_Llin` boost pressure | 0xC116 |
| `mrmM_EAKT` current quantity | 0xC0DE | | `ldmP_Lsoll` boost setpoint | 0xC278 |
| `anmWTF` coolant temperature | 0xC086 | | `armM_List` air mass actual | 0xC10A |
| `anmPWG` pedal value | 0xC068 | | `zumP_RAIL` rail pressure | 0xC20E |

The listing and function table use these names. Functions get a `chapter_guess` from the variable prefixes they write.

### Functions mapped to the function description

The writer of each key output signal, and the maps it uses:

| Function | Writes | Maps / curves used | Chapter |
|---|---|---|---|
| 0x0A80A2 | `mrmM_EPWG`, `mrmPWGfi` | **Driver demand maps** 0xF5CA4, 0xF5D94 (12×8, speed × filtered pedal 1-100 %, values 0-73 mg) | 03 |
| 0x0B1148 | `mrmM_EWUN` | Desired quantity coordination: 0xF3CFC, temperature/ADF curves | 03 |
| 0x09F52E | `mrmM_ESTAR` | **Start quantity map** 0xF5F04 (8×10, speed × coolant temperature), curve 0xF5FD0 | 03 |
| 0x0A5E46 / 0x0A5C52 | `mrmM_EBEGR` | **Smoke limitation maps** 0xF5082, 0xF52EE, 0xF566C, 0xF5A5C (16×16, speed × air mass), full-load curves 0xF555E/0xF55B4/0xF5604 (19 points over speed), temperature map 0xF4FA0, altitude curve 0xF52CA | 03 |
| 0x0A6B1C | `mrmM_EFGR`, `mrmFG_SOLL` | Cruise control: 0xF610E and curves over vehicle speed | 07 |
| 0x09F14C | `ldmP_Lsoll` | **Boost setpoint maps** 0xF4332, 0xF44F2, 0xF4780, 0xF71B4 (16×12, speed × `ram_C27A`, which uses the same 0-68 mg raster as `mrmM_EAKT`; values 198-2320, i.e. mbar), atmospheric corrections 0xF46B2, 0xF4964, temperature curve 0xF4940 | 06 |
| 0x0A466C | `ehmFLDS1`, `ehmFLDS2` | Boost actuator pilot control and controller parameters: 24 maps/curves (0xF3E28-0xF41EC ...) | 06 |
| 0x09E77C | `armM_Lsoll` | **EGR air-mass setpoint** 0xF1C60 (12×16), 0xF1F0C, corrections 0xF1E3C, 0xF1EA4, 0xF1E20 | 05 |
| 0x0BB868 | `mrmM_EWUNF`, `mrmM_DXMSR`, 0xC0C2 (quantity after external interventions) | **External interventions**: consumption map 0xF21DE, EGS drive-off curve 0xF232E, A/C feed-forward, ASC/MSR, fault-reaction limiter 0xF3B72/0xF3BA6 (see [Transmission (EGS) torque intervention](#transmission-egs-torque-intervention)) | 03 |
| 0x09E0B2 | `armM_List`, `armM_List1/2` | **HFM linearisation curves** 0xF1A92, 0xF1B16 (32 points, air-mass meter 1/2), density correction 0xF1A02 | 05 |
| 0x0B2F24 | `zumAB_NE`, `zumAD_NE2` (post-injection start/duration) | **Rail pressure × quantity map** 0xF61CC (16×32; x 119-1450 bar at 0.1 bar/bit, y 0-70 mg, values 0-5000: energising-time shape), speed × quantity map 0xF6CC8 (constant −6400 in this release) | 04 |
| 0x0B00EE | `ehmFGRS` | Glow time 0xF6C94 (battery voltage × coolant temperature), curve 0xF6C7C | 07 |
| 0x09B93A | `anmWTF`, `anmLTF2`, `anmADF`, ... | Sensor linearisation curves (coolant 0xF1868 with 24 points, intake air 0xF16D6, ...) | 02 |

These identifications come from which named variable a function writes and what its maps take as inputs. The [`out/maps.md`](out/maps.md) file also lists label names from the function description that match a map's input signals (`mrwBRA_KF` for the smoke maps, `gswGS_VGKF` for the glow map, ...). Those are hints, not confirmed names.

### Fault paths

`fault_report` (0x092006 → boot 0:2000) is called with `R0.0` = error condition, `R3 = (path << 4) | (error << 1)`, `R1` = pointer word to the debounce configuration (3 words) and `R2` = mask. [`out/fault_paths.csv`](out/fault_paths.csv) lists all 492 reports. The path numbering doesn't follow the order in appendix A of the function description.

**Fault codes.** The SGBD fault codes (`ORT`) are stored as the first word of **fault-code descriptor labels**: `<code, 16 bit LE> <0|1> 0x41 <n> 0x28 …`. There is one for every code in `FORTTEXTE`, 54 in total. The chain that ties a stored fault to its code:

1. **Fault memory read.** The read (KWP2000 service 0x18, handler 0x0AB5C4, confirmed in the EdiabasLib simulation, see below) answers each entry of the fault memory (0xC529, 28-byte entries) with the word its descriptor pointer points to. The pointer comes from the RAM table at 0xCAA2.
2. **Descriptor → debounce labels.** In the label pointer table, each descriptor label is followed by the debounce labels (`R1`) of the faults it covers.
3. **Assignment.** `tools/faultcodes.py` assigns every fault report to the nearest preceding descriptor label by label index. For the fault index `R3 >> 1` this is unambiguous: 217 indices, each with exactly one code.

The result agrees with the CAN supervision identified independently in this analysis:

| Code | Text | Fault indices | Reporting functions |
|---|---|---|---|
| 0x0600 | CAN-Bus privat | 0xAE-0xB3 | CANP checks `fn_0B1E5C` (R3 0x160-0x166), `vec_0F00C0`, `fn_09A67C`/`fn_09A7DA` |
| 0x1E00 | CAN-Bus | 0xB4-0xBA | CAN driver `fn_09970E`/`fn_09985E`, EGS1 failure 0x0BC4AA and ASC1 monitoring 0x0BC692 in `fn_0BB868` |
| 0x0120 | Pedalwertgeber | 0x17-0x1A | `fn_09AA4C`, `fn_09AC90`, `fn_0A7FC2` |
| 0x0200 | Injektor Zylinder 5 | 0xC6-0xC9 | `fn_0A34CA` |

All codes are in [`out/fault_codes.md`](out/fault_codes.md), and one row per report in [`out/fault_codes.csv`](out/fault_codes.csv).
* Some codes have descriptors but no report in the decoded application, e.g. 0x0335 crank speed and 0x0190 rail-pressure sensor; these are probably reported by the segment-0 ROM services.
* 32 reports have no debounce label and stay unassigned.

### Transmission (EGS) torque intervention

The response to the transmission's torque request (e.g. torque reduction during upshifts) is the EGS block in `fn_0BB868`, **0x0BC4BA-0x0BC6B0**. It implements function description §3.1.8.2 "EGS intervention via CAN" (figure MREXME03) step by step.

**CAN input.** The receive handler (0x097F10) reads five receive objects of the C167 on-chip CAN module (0xEF00) into 9-byte buffers (8 data bytes + status), each with a parameter block in the calibration:

| Buffer | Parameter block | Message |
|---|---|---|
| 0xC298 | 0xF1F80 (arbitration `87 E0`) | **EGS1, ID 0x43F** |
| 0xC2A2 | 0xF1FB0 (arbitration `C2 A0`) | INSTR3, ID 0x615 |
| 0xC2AC | 0xF1FDE (arbitration `2A 60`) | ASC1, ID 0x153 |
| 0xC2B6 | 0xF23C2 (arbitration `C2 60`) | INSTR2, ID 0x613 |
| 0xC2C0 | 0xF23D2 (arbitration `A5 80`) | ID 0x52C, not in the function description |

`fn_0BB868` copies the EGS1 buffer to 0xC460 and reads it through the pointer 0xD656 (set up in the init function `fn_0BB608`). The CAN configuration byte 0xF1F74 (`cawINF_CAB`, value 0x4B) enables the EGS1 (bit 0) and ASC1 (bit 1) monitoring.

| EGS1 signal | Byte / bits | Stored at |
|---|---|---|
| `GANG_INF` target gear | 0, bits 0-2 | 0xC178 |
| `S_SCHALT` shift active | 0, bit 3 | 0xC332 |
| `S_WK` converter clutch | 0, bits 6-7 | 0xC32C |
| `MD_IND_GS` torque intervention (`mroMD_EGS`) | 3 (0xFF = no intervention) | copy at 0xD8A0 |

**Normal operation** (status 0xD824 = 1):

1. Specific consumption `mroBI_SOLL` (0xC40A) = consumption map **0xF21DE** (8×8, engine speed × `mrmM_EMOT`, values ≈ 15,300-20,700).
2. EGS quantity (0xD634) = `MD_IND_GS` × `mroBI_SOLL` / 500 (0.01 mm³/bit).
3. If `MD_IND_GS` = 0xFF the driver demand passes unchanged; otherwise quantity = **min**(driver demand, EGS quantity). The intervention can only reduce quantity.

There is **no ramp, filter or delay on the DDE side**: the requested torque is applied on every pass. The shape and duration of a shift torque reduction are entirely decided by the EGS.

**EGS1 failure** (fault path 22, `fbeEEGS_F`; triggered when the buffer status shows timeout/substitute/invalid). `F_GE` is set for DDE1 (0xC317), the substitute gear is 1 (0xF1FDB), and the substitute quantity depends on vehicle speed `fgmFGAKT`:

| Condition | Substitute quantity | Status 0xD824 | Calibration (O release) |
|---|---|---|---|
| `fgmFGAKT` < `mrwV_ANFAH` | Drive-off curve `mrwANFAHKL` 0xF232E over engine speed | 8 | threshold 0xF2008 = 4500 (45 km/h); curve 45 mm³ at 600 rpm, ≈ 48 at 2000, 53-55 at 4000-4200, 0 at 4900 |
| otherwise | Ramp (`mrwEGSRAMP`) up to `mrwM_EGSMX` | 2, then 4 when reached | step 0xF2006 = 200 (2 mm³/pass), maximum 0xF200E = 10000 (100 mm³, i.e. no limit) |

Fault path 23 (0x0BC692) is the matching ASC1 message monitoring.

**Downstream.** The EGS-limited quantity (0xC43A) then passes the ASC/MSR interventions (0x0BC6B2-0x0BCA0C, writing `mrmM_DXMSR`) and is stored at 0xC0C2, and with the idle quantity added at 0xC0C8. The shift-active and converter-clutch bits are also read by `fn_0B1148` (desired quantity coordination); according to the function description the anti-jerk control switches to a separate parameter set during shifts (`camS_SAKT = mrwARDS_I`). That path isn't traced yet.

The rest of `fn_0BB868`: A/C compressor feed-forward (0x0BBA00-0x0BBCB4; input `ehmFKLI`, delay/start-percentage/ramp parameters at 0xF1FC0) and a fault-reaction quantity limiter (0x0BC0E0-0x0BC45C; collects fault bits, limits with speed curves 0xF3B72/0xF3BA6 and ramps).

### CAN controllers and master/slave link

The master drives **two** CAN controllers, although its connectors have three CAN pairs (CANP to the slave, the transmission pair X2412 pins 3/4, and the vehicle CAN pair X2414 pins 36/37; see [`E38-8HP-Conversion/CANTCU-Installation.md`](../../E38-8HP-Conversion/CANTCU-Installation.md#engine-control-can-topology)).

Each message object is set up from a 16-byte descriptor in the calibration: `+0x0B` object offset in the controller (object number × 0x10), `+0x0C` data length, `+0x0D/+0x0E` arbitration (ID << 5), `+0x0F` message configuration (DLC << 4, bit 3 = transmit). The 82527 and the C167 on-chip CAN module share this register layout.

**C167 on-chip CAN, 0xEF00: vehicle and transmission CAN.** Initialised by `sub_097B28` (bit timing from label 0xF1F7E), objects set up by `sub_099802` (descriptors 0xF1F80-0xF23D2), received by `fn_097F10` / `sub_097D46`, transmitted by `sub_097CF2` (task `fn_099630`):

| Object | ID | Direction | Message | Descriptor | RAM buffer |
|---|---|---|---|---|---|
| 1 | 0x43F | RX | EGS1 | 0xF1F80 | 0xC298 |
| 2 | 0x316 | TX | DDE1 | 0xF1F90 | 0xC124 |
| 3 | 0x329 | TX | DDE2 | 0xF1FA0 | 0xC12C |
| 4 | 0x615 | RX | INSTR3 | 0xF1FB0 | 0xC2A2 |
| 5 | 0x153 | RX | ASC1 | 0xF1FDE | 0xC2AC |
| 6 | 0x545 | TX (DLC 4) | DDE4 | 0xF1FEE | 0xC134 |
| 7 | 0x613 | RX | INSTR2 | 0xF23C2 | 0xC2B6 |
| 8 | 0x52C | RX | not in the function description | 0xF23D2 | 0xC2C0 |

Since a single controller serves EGS1, ASC1, INSTR2/3 and the DDE transmit messages, the transmission pair and the vehicle CAN pair must be the same bus electrically, i.e. connected inside the master DDE. This fits the function description (chapter 9.1, one CAN controller) but the physical link still has to be confirmed by measurement.

**External Intel 82527, 0xB000: private master/slave CAN (CANP).** Initialised by `can_controller_init` (0x09664E: CPU interface register `+0x02` = 0x60, bit timing `+0x3F`/`+0x4F`, port configuration `+0x9F`/`+0xAF`), RAM test `sub_0966DE`, objects set up by `sub_09A75E` (descriptors 0xF23F0-0xF24A0). The IDs are private and don't appear on the vehicle CAN:

| Object | ID | Direction | Descriptor | RAM buffer |
|---|---|---|---|---|
| 1-6 | 0x010, 0x018, 0x020, 0x028, 0x030, 0x038 | TX | 0xF23F0-0xF2440 | 0xC13C, 0xC144, 0xC14C, 0xC154, 0xC15C, 0xC164 |
| 7-11 | 0x040, 0x048, 0x050, 0x058, 0x060 | RX | 0xF2450-0xF2490 | 0xC2CA, 0xC2D4, 0xC2DE, 0xC2E8, 0xC2F2 |
| 12 | 0x008 | RX, interrupt `vec_0F00C0` | 0xF24A0 | 0xC21C/0xC21E, 0xC224/0xC226 |

The slave has the mirror image on its on-chip CAN (see [`../DDE41B-RE`](../DDE41B-RE/README.md#master-slave-can-link)).

#### CANP protocol

One task, `fn_0B1E5C`, handles the whole cyclic exchange on the master: it unpacks the five slave frames (0x0B1E5C-0x0B26D8) and packs the six master frames (0x0B26DA-0x0B2E3A). The slave's `fn_0A2466` does the reverse. The protocol has these elements:

- **Multiplex counter.** Byte 0 of 0x010 is the master's counter 0xD4A8, which counts 0-9 and then wraps (+1 per cycle). The slave echoes it in byte 0 of 0x060 (slave 0xC8F6 → master 0xD4A9). Bit 0 of the counter selects one of two contents for frames 0x018-0x038 and 0x040-0x058 (variant A = even, B = odd). The full value selects one of ten slots in 0x060.
- **Checksum.** `sub_0B1DE0` (slave: `sub_0A2354`) runs over all frames of one direction, seeded with 0x3039. The result goes in byte 1 of the first frame (0x010) or last frame (0x060).
- **Supervision** (fault path 0x16, the CAN path): echo mismatch → `R3` = 0x160 (label #694); 0x008 object status → 0x162 (#695); handshake timeout → 0x164 (#696); checksum error → 0x166 (#697). On an echo mismatch the status 0xD4A9 is 0x20 and the multiplexed values keep their last state. On a checksum error, or once the echo fault is confirmed, it becomes 0x10 and all slave-supplied values are replaced by the substitute block at label #320 (0xF24D4). The same block also provides the start-up values (`fn_0B1B98`).
- **Handshake for 0xC22A.** 0xC22A is the post-injection duration that `fn_0B2F24` writes together with `zumAB_NE`. A change to it is transferred in two phases (state 0xD4A3, repeat counter 0xD4A2, limits at label #321 0xF2516). The master sends the new value in 0x020 bytes 2-3 (0xD4A6). The slave applies it as its `zumAD_NE` and echoes it in 0x058 bytes 0-1. The master takes the value over only after it receives the echo, so both banks switch post-injection together.

**Master → slave** (16-bit words unless noted; names from the SGBD, otherwise the RAM address with the function that writes it):

| Frame | Bytes | Variant A (even counter) | Variant B (odd counter) |
|---|---|---|---|
| 0x010 | 0 / 1 | counter 0xD4A8 / checksum | same |
| | 2-3 | `ldmADF` | 0xC22E (fuel pump / metering-unit control `fn_0BA898`) |
| | 4-5 | counter 0, 2, 4, 6, 8: 0xC072, 0xC076, 0xC07A (analog inputs, `fn_09B93A`), `anmLTF2`, 0xC0E6 (A/C, `fn_0B4A14`) | `mrmCASE_A` |
| | 6-7 | `mrmCASE_L` | `mrmCASE_L` |
| 0x018 | 0 / 1 | 0xC338 (digital inputs, `fn_096F32`) / 0xC312 (status from `fn_09F52E`/`fn_0B8ADA`) | 0xC300 (`mrmSTATUS` logic) / 0xC312 |
| | 2-7 | `ehmFEKP`, `anmUBT`, 0xC11A (boost actuator, `fn_0A466C`) | 0xC0F8 (`fn_0B1148`), 0xC100 (start quantity, `fn_09F52E`), 0xC31A (byte: fault-reaction limiter ramp active, `fn_0BB868`) |
| 0x020 | 0-7 | `zumAB_NE`, handshake value 0xD4A6, `mrmSTATUS`, `fgmFGAKT` | 0xC31C (byte, pedal, `fn_0A80A2`), 0xC344 (byte, digital inputs), 0xC212 (`mrmSTATUS` logic), 0xC194, 0xC196 (`fn_0B3A40`) |
| 0x028 | 0-7 | 0xC301 (byte), 3 bytes from 0xC294, 0xC016, `mrmKM_akt` | 0xC35D (byte), 3 bytes from 0xC294, 0xC016, `mrmKM_akt` |
| 0x030 | 0-7 | 0xC35F (byte), 0xC31B (byte, pedal), `armM_List`, 0xC35A (byte, sign-extended), 0xC1B0 (fuel pump) | 0xC35F (byte), 0xC342 (byte, digital inputs), `fbmBSTZ_UB`, 0xC0B0 (start quantity), `anmWTF` |
| 0x038 | 0-7 | 0, `mrmM_ESTAR`, **`mrmM_EWUN`**, `mrmM_EBEGR` | `anmVDF`, `mrmM_ESTAR`, **`mrmM_EWUN`**, `mrmM_EBEGR` |

**Slave → master** (slave source → master destination; slave RAM addresses are the slave's own):

| Frame | Bytes | Variant A (even counter) | Variant B (odd counter) |
|---|---|---|---|
| 0x040 | 0-7 | slave 0xC259 (speed, `fn_096344`) → 0xC311; `zhmUM_ZA` → `zhmUM_ZA`; `zumP_RAIL` → `zumP_RAIL`; slave 0xC29C (rail pressure control) → 0xC359; slave 0xC0BA → 0xC022 | slave 0xC289 → 0xD4B4; slave 0xC270 → 0xC35C; `zumP_RAIL` → `zumP_RAIL`; slave 0xC1BC, 0xC1BE (sensors, `fn_09BB7E`) → 0xC1DA, 0xC1E8 |
| 0x048 | 0-7 | `dzmNakt` → **`dzmNmit`**; `mrmM_EAKT` → `mrmM_EAKT`; `mrmM_ELLR` → `mrmM_ELLR` (and 0xC0DC = min(`mrmM_ELLR`, `mrmM_EBEGR`)); `mrmM_EMOT` → `mrmM_EMOT` | same (not multiplexed) |
| 0x050 | 0-7 | slave 0xC0B4-0xC0B7 → 0xC01C-0xC01F; slave 0xC14A, 0xC14C (surge damper, `fn_0A0110`) → 0xC0C4, 0xC0C6 | `sub_0A23F0` result → 0xC16C; slave 0xC0BA → 0xC022; 0xC14A, 0xC14C → 0xC0C4, 0xC0C6 |
| 0x058 | 0-7 | handshake echo (slave `zumAD_NE` input 0xC8F4) → 0xD4A6; `mrmLLRPAnt`, `mrmLLRIAnt` → same names; `mrmN_LLBAS` → 0xC216 | `anmLMM1` → `anmLMM1`; slave 0xC114 (air-mass meter 1) → 0xC054; `anmLDF1` → `anmLDF1`; slave 0xC02E (injection, `fn_0951A4`) → 0xC210 |

Frame 0x060 carries the echoed counter (byte 0) and the slave checksum (byte 1). Bytes 2-7 depend on the counter (slave jump table at 0xF064E, master cases at 0x0B2406-0x0B2584):

| Counter | Content (slave → master) |
|---|---|
| 0 | slave 0xC020 → 0xC0AC; **slave `fbmSDIAL`** (diagnostic lamp request) → 0xC306, ORed into the master's `fbmSDIAL`; slave 0xC293 (fault handling) → 0xC30E, ORed into 0xC30F |
| 1 | slave 0xC29E low nibble → 0xD4AC, ORed into 0xC345; `zumPQsoll` → `zumPQsoll` |
| 2 | `anmLTF1` → `anmLTF1`; `zumAB_HE` → `zumAB_HE`; slave 0xC066 (injection) → 0xC236 |
| 3 | slave 0xC116 (sensor processing) → 0xC070; `zumPQsoll` |
| 5 | slave 0xC092 → 0xC206; `zumPQsoll`; slave 0xC090 → 0xC208 |
| 7 | slave 0xC19C → 0xC106; `zumPQsoll` |
| 9 | `zumPQsoll`; slave 0xC08A (rail pressure control, `fn_0A37DC`) → 0xC21A |
| 4, 6, 8 | counter only |

So the slave reports engine speed, the quantities after surge damping and idle control (`mrmM_EAKT`, `mrmM_EMOT`, `mrmM_ELLR` and its P/I parts), rail pressure and setpoint, main injection timing, its sensors (air mass 1, boost 1, intake air 1) and its diagnostic-lamp request. The master merges these into its own variables and its CAN output. The master has no speed or surge-damper calculation of its own: `dzmNmit`, `mrmM_EAKT` and `mrmM_EMOT` are written only here and in the start-up/substitute path. So `N_MOT` in DDE1, for example, is the slave's engine speed.

#### Frame 0x008 (slave → master, crank-synchronous)

The slave sends 0x008 from its segment-0 ROM. The application (`fn_09695E`) only stores the object pointers 0xF93C/0xF938 (data address 0xEFC7) and the control bytes 0xA5/0xE6 (transmit request) at 0xF93A. On the master, the receive interrupt `vec_0F00C0` decodes it:

| Byte | Content | Master |
|---|---|---|
| 0, bits 0-3 | slave synchronisation status flags | → status word 0xC512 → 0xC1F8 (bits 0, 3, 6, 15; no frame: 0x4001) |
| 0, bits 4-7 | slave segment counter | → 0xC51C → **0xC357** |
| 1, bit 0 | no data in this frame (counter advanced only) | |
| 2-5 | two 16-bit values | even counter → 0xC21C/0xC21E, odd counter → 0xC224/0xC226 |

`fn_095C00` compares the slave's segment counter 0xC357 with the value expected for the master's own segment counter 0xC356 (table at label #363, 0xF6728) and counts mismatches in 0xF832. `fn_0960E0`, the master's segment task, takes the data words of the matching segment. It checks how old they are against its own segment time (remainder of the `DIVLU` in `MDH`) and keeps per-bank minimum/maximum values in 0xDE40-0xDE72. 0x008 is therefore the crank-angle synchronisation check between the two banks: the slave reports which segment it is in plus its segment timing. The exact physical meaning of the two data words (time stamp vs. angle) isn't confirmed, because the sending code is in the slave ROM.

#### Transmission intervention and the slave

None of the vehicle CAN messages are forwarded to CANP. The transmission's torque request reaches the slave only as its result: EGS1 → `MD_IND_GS` → minimum with the driver demand (0xC0C2, written at 0x0BD0E6) → `fn_0B1148` → **`mrmM_EWUN`** (0xC0C0, SGBD: "Fahrerwunschmenge nach externem Mengeneingriff") → CANP frame 0x038, bytes 4-5. No raw EGS1 byte and no transmission-derived flag (gear 0xC178, shift active 0xC332, converter clutch 0xC32C) is packed. 0xC31A in 0x018 variant B comes from the fault-reaction limiter in `fn_0BB868` (0x0BC2C4), not from the EGS block. The 3 bytes at 0xC294 have no writer in the visible code; they lie outside the EGS1 buffer (0xC298-0xC2A0).

## Diagnostic protocol (EDIABAS / INPA)

The diagnostic tooling in this repository was used to tie the BMW diagnostics to the firmware:
* the EdiabasLib interpreter ([`../../Shared/EdiabasLib`](../../Shared/EdiabasLib/README.md), MIT);
* the SGBDs of `../../Shared/SP-Daten/E38/ecu` and `../../Shared/BMW-StandardTools`;
* the INPA scripts of `../../Shared/BMW-StandardTools/EC-APPS/INPA/SGDAT`.

**Protocol** (`INITIALISIERUNG` and the simulator trace). K-line at 9600 Bd. Telegram `B8 <ecu> F1 <len> <SID> <data> <XOR>`: master **0x12**, slave **0x13**, tester 0xF1, XOR checksum (verified: the simulator only accepts XOR-checked answers).

| Service | Request | Use |
|---|---|---|
| Read measurement values | `2C 10 <ID hi> <ID lo> …` (dynamically defined local identifier, several IDs per request) → `6C 10 <2 bytes per ID>` | all live values; the ID is the key of the firmware measurement table at 0x91000 |
| Read fault memory | `18 00 00 00` (list of stored codes), then `17 <code hi> <code lo>` per fault (status and environment) | `FS_LESEN`; the codes are the descriptor words above |
| Read local identifier | `21 06` | `STATUS_SYNC_MODE` |

**Status jobs, measured** ([`out/ediabas_status.md`](out/ediabas_status.md) / [`.csv`](out/ediabas_status.csv), tool `tools/ediabas_probe.py`). Every `STATUS_*` job of `DDE41KR0.prg` was run with its original job code in the EdiabasLib simulator. The tool learns each request from the trace, answers it, and then varies every data byte and bit.

| Result | Count |
|---|---|
| Jobs that run to `OKAY` | 142 of 142 |
| Numeric values with bytes, byte order, factor, offset and sign | 154 |
| Digital status bits with byte/bit position | 13 |
| Jobs whose measurement IDs resolve to a RAM address | 141 |
| Factors that differ from `BETRIEBSWTAB` (apart from raw-value debug results such as `STAT_ROHWERT1/2`) | none |

Findings beyond the static decode:

- **Smooth-running values live in the slave.** The master SGBD's `STATUS_LAUFUNRUHE_DREHZAHL` and `STATUS_LAUFUNRUHE_LLR_MENGE` send their 16 IDs (0x0F13-0x0F1E, 0x2F80/81, 0x2F86/87) to address **0x13**. These IDs aren't in the master's measurement table; they are the slave's per-cylinder values `dzmzN1-8` (0xC1D6-0xC1E4) and `dzmzMk1-8` (0xC1E6-0xC1F4). The probe joins requests to the table of the addressed ECU.
- **`STATUS_DIGITAL`** reads 9 IDs in one `2C` request (2 bytes per ID; response bytes 6-7 = first ID, and so on). The measured bit positions give, for example:
  * brake light switch = bit 0 and brake test switch = bit 1 of the first byte of ID 0x0F70 (RAM 0xC17E), glow controller = bits 4/5;
  * clutch switch = bit 5 of the second byte of ID 0x0F70;
  * cruise control "off" and "decelerate" = active-low bits 5/6 of the second byte of ID 0x2F74 (RAM 0xC17C);
  * A/C request and A/C compressor = bit 0 of the second byte of the last two IDs (0x1FB0/0x1FB1 → 0xC32A/0xC32B).

  Two cruise-control results never changed in the bit sweep, so they are probably fixed by the job itself.
- **Signed values.** The job code treats 61 results in 45 jobs as signed 16-bit:
  * all injection quantities (`mrmM_E*`);
  * the post-injection start/duration values (`zumAB_HE`, `zumAB_NE`);
  * the idle-controller P/I parts;
  * the voltages (`anmUBT`, `admUC1/2`, …);
  * the raw A/D values (`anoU_*`).

  The sign matters when you read these over CAN or with your own tools.

**INPA** ([`out/inpa_screens.md`](out/inpa_screens.md), tool `tools/inpa.py`). These are the screens of `DDE41R.IPO` (diagnosis) and `10DDE41A.ipo` (programming), with the labels and SGBD results each screen shows.
* Status pages: Digital, Analog 1-5. Analog 4/5 show the per-cylinder quantity correction and smooth-running values from the slave, see above.
* Other pages: actuator tests 1/2, adjustment and EWS 3.
* The INPA scripts of both ECUs call `STEUERN_AGB_STELLER1/2`, which doesn't exist in either SGBD (the jobs are named `STEUERN_AGR_STELLER1/2`). So the EGR actuator test from those INPA screens fails; run the SGBD job directly instead.

## Output files

| File | Content |
|---|---|
| [`bin/`](bin) | Flat binaries: program (0x80000), data (0xF0000), combined 512 KB image (0x80000-0xFFFFF) |
| [`out/listing.asm`](out/listing.asm) | Full disassembly with labels, call/jump targets, RAM names and resolved calibration labels |
| [`out/functions.csv`](out/functions.csv) | Functions: size, callers/callees, named variables read/written, chapter guess |
| [`out/maps.md`](out/maps.md) / [`maps.csv`](out/maps.csv) / `maps.json` | All curves and maps with axes, values, users, doc candidates |
| [`out/labels.csv`](out/labels.csv) | The 783 calibration labels: type, size, value, users |
| [`out/measurement_table.csv`](out/measurement_table.csv) | Measurement ID → RAM address → SGBD name, unit, scaling |
| [`out/fault_paths.csv`](out/fault_paths.csv) | Fault report call sites |
| [`out/fault_codes.md`](out/fault_codes.md) / [`fault_codes.csv`](out/fault_codes.csv) | SGBD fault code (German/English text, environment) per descriptor, and per fault report |
| [`out/ediabas_status.md`](out/ediabas_status.md) / [`ediabas_status.csv`](out/ediabas_status.csv) | All `STATUS_*` jobs measured in the EdiabasLib simulator: requests, byte layout, scaling, RAM variable |
| [`out/inpa_screens.md`](out/inpa_screens.md) | INPA screens (`DDE41R.IPO`, `10DDE41A.ipo`) with labels and SGBD results |
| [`out/calrefs.csv`](out/calrefs.csv), [`out/scalars.csv`](out/scalars.csv) | Every calibration access; calibration words read directly (not via labels) |
| [`out/topsector.asm`](out/topsector.asm), [`topsector.md`](out/topsector.md) | Top flash sector disassembly (only with a full flash read in `bin/*.ori`) |
| [`sgbd/`](sgbd) | `DDE41KR0.prg` decoded: info, 232 jobs, all tables as CSV |

## Tools

All tools are plain Python 3 with no dependencies, and are shared with the slave analysis [`../DDE41B-RE`](../DDE41B-RE/README.md). Choose the ECU with `--variant` (or the environment variable `DDE_VARIANT`). To regenerate everything:

```powershell
cd DDE41A-RE\tools
python run_all.py --variant A   # master -> DDE41A-RE
python run_all.py --variant B   # slave  -> DDE41B-RE
python run_all.py --variant A --ediabas   # also re-measure the SGBD status jobs in the EdiabasLib simulator (about 15 min)
```

Inputs: the E38 SP-Daten in [`../../Shared/SP-Daten/E38`](../../Shared/SP-Daten/E38) (programming data, SGBDs), the EDC15C function description in [`../../Shared/Documentation/EDC15C-Function-Description`](../../Shared/Documentation/EDC15C-Function-Description) (map name hints), and BMW Standard Tools in [`../../Shared/BMW-StandardTools`](../../Shared/BMW-StandardTools) (English SGBDs, INPA scripts). `--ediabas` needs the shared `EdiabasTest.exe` (see [`../../Shared/EdiabasLib/README.md`](../../Shared/EdiabasLib/README.md)).

| Tool | Purpose |
|---|---|
| [`variant.py`](tools/variant.py) | Variant selection (paths, SGBD), detection of the measurement table, label table and end of data |
| [`hex2bin.py`](tools/hex2bin.py) | Intel HEX `.0PA`/`.0DA` → binary (checks record checksums, prints `$REFERENZ`/`$CHECKSUMME`) |
| [`c166.py`](tools/c166.py) | C166/C167 instruction decoder (full instruction set, SFR names, `EXTP`/`EXTS` handling) |
| [`analyze.py`](tools/analyze.py) | Recursive descent with sweep-based function discovery, DPP/EXT address resolution, call graph, listing |
| [`sgbd.py`](tools/sgbd.py) | EDIABAS `.prg` decoder (XOR 0xF7): info, jobs, tables |
| [`meastab.py`](tools/meastab.py) | Firmware measurement table (located automatically) joined with the SGBD `BETRIEBSWTAB` |
| [`maps.py`](tools/maps.py) | Curve/map detection, value order, axis naming, code links, doc candidates |
| [`topsector.py`](tools/topsector.py) | Top flash sector (0xFC000-0xFFFFF) from a full flash read: RAM blocks at their run addresses, in-place loader |
| [`params.py`](tools/params.py) | Label table, direct scalars, fault-path report table |
| [`faultcodes.py`](tools/faultcodes.py) | Fault-code descriptor labels → SGBD fault codes for every fault report (checks that each fault index maps to exactly one code) |
| [`ediabas_probe.py`](tools/ediabas_probe.py) | Runs the SGBD's `STATUS_*` jobs in the EdiabasLib simulator: learns the requests, measures byte layout/scaling/bits, joins measurement IDs to RAM (per diagnostic address, so slave IDs requested by the master SGBD resolve) |
| [`inpa.py`](tools/inpa.py) | INPA screens from the compiled `.IPO` scripts; flags job/result names missing from the SGBD |
| [`c166_is_ref.txt`](tools/c166_is_ref.txt) | Opcode reference table from [hn/c166-dis](https://github.com/hn/c166-dis) (GPL-3.0), used only to cross-check the decoder |

## Limitations

- **Segment-0 code not available.** The scheduler, interpolation routines and fault manager live in segment 0 (0x0000-0x7FFF). That is most likely the C167's internal mask ROM, which isn't in any flash file or flash read. Their behaviour is inferred from call sites only. See [Segment-0 services](#segment-0-services-internal-rom).
- **Function boundaries are heuristic.** About 10% of the program content isn't decoded; it's mostly constant tables. Functions named `fn_xxxxxx` start after a return or boot-task stub, while `sub_xxxxxx` are confirmed call targets.
- **Scaling.** Map values are raw. Axis scaling from the SGBD is shown only as a hint, because the SGBD scales the diagnostic telegram value, which for some signals is a byte (e.g. `zumP_RAIL`).
- **Names.** Only 127 of the 260 measured RAM variables have SGBD names. Calibration label names (`mrw...`, `ldw...`) aren't stored in the image, so map names are evidence-based candidates.
- **Fault path names.** The path numbers themselves have no names. The SGBD fault code of each report is resolved through the descriptor labels (see [Fault paths](#fault-paths)); 32 reports without a debounce label remain unassigned.
- **Simulator coverage.** The EdiabasLib probe covers the `STATUS_*` jobs. Actuator (`STEUERN_*`), adjustment (`ABGLEICH_*`) and coding jobs weren't run.
- **Slave ECU.** The slave (DDE41B, `7787317O`) is covered separately in [`../DDE41B-RE`](../DDE41B-RE/README.md).

## Top flash sector (from the full flash read)

`tools/topsector.py` disassembles 0xFC000-0xFFFFF from the full flash read (`bin/*.ori`). That sector isn't in the SP-Daten files. Output: [`out/topsector.asm`](out/topsector.asm) and [`out/topsector.md`](out/topsector.md).

| Block | Flash | Runs at | Decoded | Role (evidence) |
|---|---|---|---|---|
| RAM block 1 | 0xFC000-0xFC2FF | 0xC000 (external RAM) | 534 bytes | **Checksum/verify**: steps through memory with `EXTP`, adds up bytes into 0xFAF8 |
| RAM block 2 | 0xFC300-0xFC5FF | 0xE000 (XRAM) | 656 bytes | **Flash erase driver**: AMD command address `0x2AAA`, erase confirm `0x30`, status polling on data bit 7 (`AND #0x80`) |
| RAM block 3 | 0xFC600-0xFC8FF | 0xE300 (XRAM) | 670 bytes | **Flash program driver**: `0x2AAA` command sequence, status polling on data bit 7 |
| In-place block | 0xFCC00-0xFEBF9 | in place (segment 0x0F) | 8142 bytes | **Reprogramming communication layer**: K-line serial setup (`S0CON = 0x8067`), KWP2000 dispatcher, calls 25 ROM routines |
| ID area | 0xFEBFA-0xFFFFF | | | `97 C1` marker, Bosch number `281001843`, `B101EWS000`, references |

RAM blocks start with `A5A5` followed by 32-bit words: data pointer, two code entry points, end address (run address = end - 0x300), info. They end with `97 C1` + checksum at +0x2FA. They're copied to RAM because flash can't execute code while it's being erased or programmed.

**KWP2000 in this layer** (dispatcher at 0x0FCEA2):

- **Programming state** (flag 0xFC70 = 0xDC): services 3E, 10, 31, 32, 33, **34** RequestDownload (0x0FDC28), **36** TransferData (0x0FDF20), **37** TransferExit (0x0FE364), A2.
- **Otherwise**: 82, 83, **27** SecurityAccess (0x0FDA24), 1A, 21, 3B, 30, **23** ReadMemoryByAddress (0x0FE22A), 31.
- **Download** answers `0x33` (security access denied) until `SEED_KEY` has succeeded, and checks the target segment.
- **Memory read in programming mode** applies the same address checks as the application: 0xF0000-0xFBFFF, 0xDFF00-0xDFFFF, from 0xFEC00, and 0xFF900-0xFFC20. **Segment 0 (the internal ROM) is rejected**, so `FLASH_LESEN` can't read it either.

## Segment-0 services (internal ROM)

The scheduler, interpolators and fault manager that the application calls as `CALLS 0:xxxx` are **not in any flash file or flash read**. The evidence points to the C167's internal 32 KB mask ROM at 0x0000-0x7FFF.

What was checked:

- **SP-Daten:** none of the 505 flash files in `E38\data` contain this code. Some M57 (DDE4.0) releases (`7789376V`, `7790220V`, …) have content in 0x88000-0x8FFFF, but that is application overflow.
- **Full read of the external flash** (`bin/BMW_E38_3.9D_180KW_0281010843_1037351475_Bosch__.ori`, 512 KB, 0x80000-0xFFFFF):
  - **Stock O release.** Program and calibration are byte-identical to `7787316O` / `Y7787646`. The only difference is 4 bytes at 0x93FFA-0x93FFF, in the 32-byte trailer at the end of the 64 KB block 0x90000 (Intel-HEX type 0x10 record, which carries checksum/flag words): the update file has `91 C3 .. .. 95 14`, the dump `97 C1 .. .. 9F 16`. Bits are both set and cleared, so it's a different trailer value rather than bits programmed into erased flash; code and calibration aren't affected. The calibration isn't modified.
  - **0x80000-0x87FFF** is `C3` filler, and **0x88000-0x8FFFF** is zeros: no code. None of the segment-0 entry points (0:02D6, 0:0830, 0:0CB2, 0:0CDC, 0:2000) exist in external flash.
  - **0xFC000-0xFFFFF (top 16 KB sector)** isn't in any update file. It holds three 0x300-byte code blocks with `A5A5` headers listing RAM load addresses (0xC0xx, 0xE0xx, 0xE3xx) and `97 C1` trailers, a larger code block (0xFCC00-0xFEBF9), and an ID area (`281001843`, `B101EWS000`, references). This looks like the flash-programming layer that runs from RAM. This code also calls segment 0, at targets from 0:02D6 up to 0:799C.
- **Conclusion:** all segment-0 call targets (application up to 0:28A0, top sector up to 0:799C) lie in 0x0000-0x7FFF. That is exactly the internal ROM window of a C167 "…RM" variant (32 KB), and that ROM never appears in external flash.
- **Diagnostic read in normal mode:** the application implements KWP2000 itself. The service dispatcher compares the service ID at 0x0AD140-0x0AD1D8, and service 0x23 ReadMemoryByAddress is handled at 0x0AB468. The handler accepts at most 0x32 (50) bytes per request and only these ranges:

  | Allowed range | Content |
  |---|---|
  | 0x0F0000-0x0FBFFF | Calibration data |
  | 0x0DFF00-0x0DFFFF | Identification block |
  | 0x0FEC00-0x0FFFFF | Top flash sector (ID area) |

  Segment 0 isn't reachable this way.

Ways to obtain the internal ROM:

1. **Code executing on the C167.** The ROM can only be read by the CPU itself. One way is a small routine loaded through the C167 bootstrap loader (boot-mode pin + serial) that copies 0x0000-0x7FFF out over the serial port. Some bench tools for EDC15 offer this. A chip programmer reading the external flash won't capture it.
2. ~~`FLASH_LESEN` in the programming session~~: ruled out. The programming-mode read handler in the top sector (0x0FE22A) rejects segment 0 (see [Top flash sector](#top-flash-sector-from-the-full-flash-read)).

The master and slave call the same entry points, so the ROM is very likely identical in both.
