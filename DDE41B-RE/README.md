# DDE41B (M67 slave ECU), O release: reverse engineering

Static analysis of the BMW E38 740d (M67D39) **slave** DDE4.1 control unit, Bosch EDC15C, software release **O**. It's the counterpart of the master analysis in [`../DDE41A-RE`](../DDE41A-RE/README.md). The method, file formats and tools are the same, so this document focuses on what is specific to the slave.

| | |
|---|---|
| Program | [`7787317O.0PA`](../BMW-SPdaten-v.60.1/E38/data/DDE41B/7787317O.0PA), 0x80000-0xEFFFF (content only in 0x90000-0xAFFFF) |
| Data | [`Y7787648.0DA`](../BMW-SPdaten-v.60.1/E38/data/DDE41B/Y7787648.0DA), 0xF0000-0xFBFFF |
| Assembly / Bosch IDs | 7787647, `CC0099884455`, Bosch HW 1037351476, slave marker `B098EWS…` |
| Diagnostic SGBD | [`DDE41KL0.prg`](../BMW-SPdaten-v.60.1/E38/ecu/DDE41KL0.prg) ("DDE 4.1 fuer M67 Slave", 157 jobs) |
| CPU | Infineon C167 |

## Results at a glance

| Item | Slave (DDE41B) | Master (DDE41A), for comparison |
|---|---|---|
| Program content | ≈ 105 KB (0x90000-0xAFFFF) | ≈ 177 KB (0x90000-0xBFFFF) |
| Code decoded | 28,919 instructions / 94 KB (≈ 90%) | 47,790 / 158 KB |
| Functions | 496 | 638 |
| Segment-0 (ROM) services called | 53 | 50 |
| Measurement table | **0x090800**, 175 IDs; all 99 SGBD IDs resolved | 0x091000, 260 IDs |
| Label pointer table | 0xF1000-0xF1435, **539 labels** | 783 labels |
| Curves / maps | 50 KL + 14 KF (10 KF are constant) | 87 KL + 55 KF |
| Fault reports | 206 call sites on 16 paths | 492 on 31 paths |

## Differences from the master

The slave runs the same software platform. These parts are identical to the master:

- `init_from_boot` at 0x090082, with DPP0 = 0x3C and DPP1 = 0x3D
- the `55 AA` jump table at 0x092000
- `fault_report` at 0x092006 → boot 0:2000
- the segment-0 (internal ROM) interpolators `boot_KL_interp` (0:0CB2) and `boot_KF_interp` (0:0CDC)
- the bus configuration in `init_bus_config` (0x091970)

What differs:

- **Measurement table at 0x090800.** The marker bytes are `55 AA` (stored as word 0xAA55; the master stores 0x55AA). The tools find the table by its structure rather than a fixed address.
- **Different RAM layout.** The same signal lives at a different address than in the master, e.g. engine speed `dzmNakt` = 0xC016 and rail pressure `zumP_RAIL` = 0xC02C. Every name in `out/` comes from the slave's own measurement table.
- **CAN: on-chip controller only.** The master drives two controllers: the C167 on-chip CAN (0xEF00) for the vehicle and transmission CAN, and an external Intel 82527 at 0xB000 for the private master/slave CAN (CANP). The slave configures the 0xB000 address window in `init_bus_config` but never accesses it. Its only CAN controller is its own **on-chip CAN module at 0xEF00**, which is connected to CANP. See [Master-slave CAN link](#master-slave-can-link). The slave also uses the ASC0 serial interface (`S0TBUF`/`S0RBUF`, e.g. 0x098A4C, 0x09853C); since the master/slave data runs over CANP, this is most likely the K-line.
- **Master-supplied signals.** `fn_0A20FC` initialises the slave's copies of master signals (`anmWTF`, `ldmADF`, `mrmM_EWUN`, `fgmFGAKT`, …) from the calibration block at label 0xF1710 (start-up values). During operation `fn_0A2466` overwrites them with the values received from the master over CANP.
- **Unused calibration.** 10 of the 14 maps are constant (e.g. 0xF21F4 quantity drift = 0, 0xF5016 = 13500). The data set carries functions that the slave doesn't use.

## What the slave computes

Functions found from the variables they write (column `chapter_guess` in [`out/functions.csv`](out/functions.csv)):

| Function | Writes | Maps / curves used | Chapter |
|---|---|---|---|
| 0x0951A4 | `zumAB_HE` (main injection start), `zuoAB_VE1`/`zuoAD_VE1` (pilot start/duration), `zuoAD_HE` (main duration), `zuoMEHE`, `zuoME_VE` | **Energising-time maps 0xF3216 and 0xF367E** (16×32, rail pressure 119-1450 bar × quantity 0-70 mg, values 0-5000), **main injection timing map 0xF25F2** (16×8, speed × `mrmM_EMOT`), rail-pressure curves 0xF4436, 0xF4E7A, speed curve 0xF306E, temperature curves 0xF567A, 0xF569E | 04 |
| 0x0A37DC | `zumPQsoll` (rail pressure setpoint), `ehmFKDR` (pressure control valve duty) | **Rail pressure map 0xF2ED2** (8×8, speed × `zumPQsoll` axis 200-1350 bar, values 1100-4300), curve 0xF4FF2 | 04 |
| 0x0A0994 | `mrmM_EAKT`, `mrmM_EMOT`, `mrmM_EKORR`, `mrmM_EFAHR`, `mrmM_EDELB` | Quantity drift map 0xF21F4 (`mrmM_EMOT` × operating hours `fbmBSTZ_UB`; all 0 in this release) | 03 |
| 0x0AB24C | `mrmM_ELRR` (smooth-running control quantity) | Curves 0xF232E, 0xF2342, 0xF2356 over `mrmM_EMOT` | 03 |
| 0x09F5F6 | `mrmM_ELLR`, `mrmLLRIAnt`, `mrmLLRPAnt` (idle controller) | Parameters via labels | 03 |
| 0x0A5592 | `dzmzN1-8`, `dzmzMk1-8` (per-cylinder speed / segment values) | | 02 |
| 0x096344 | `dzmNakt` (engine speed) | | 02 |
| 0x09ABEA, 0x09AD0A, 0x09AFC2, 0x09B582 | `anmKDF` (rail pressure sensor), `anmUC1/2` (capacitor voltages), `anmLDF1` (boost 1), `anmLMM1` (air mass 1), `anmIDV` (pressure control valve current), `anmLTF1`, `anmUBT`, … | Sensor linearisation curves 0xF1446, 0xF1592, 0xF15BA, 0xF149E, 0xF14BE, 0xF15E2, 0xF1466, 0xF14FA, … | 02 |
| 0x0A20FC | Master-supplied signals (start-up values) | Initial value block, label 0xF1710 | 09 |
| 0x0A2466 | Master-supplied signals (`mrmM_EWUN`, `mrmM_ESTAR`, `fgmFGAKT`, `anmWTF`, `anmUBT`, `mrmSTATUS`, …) | Unpacks the CANP frames 0x010-0x038 | 09 |

This matches the split in the diagnostic SGBDs. Only the slave SGBD `DDE41KL0` has per-cylinder speed (`DZMZN1-8`), injection outputs (`ZUO*`) and `STATUS_RAILDRUCK`. The master SGBD has the driver-demand, torque, CAN and most actuator jobs.

## Master-slave CAN link

The slave is connected to the master only through the private CAN (CANP; wiring in [`../CANTCU-Installation.md`](../CANTCU-Installation.md#engine-control-can-topology)). On the slave this is the C167 on-chip CAN module at 0xEF00. Its message objects mirror the master's external 82527 (see [`../DDE41A-RE`](../DDE41A-RE/README.md#can-controllers-and-masterslave-link)):

| Object | ID | Slave | Master (82527) | Slave descriptor | Slave RAM buffer |
|---|---|---|---|---|---|
| 1-6 | 0x010, 0x018, 0x020, 0x028, 0x030, 0x038 | RX | TX | labels #245-#250, 0xF161A-0xF1674 | 0xC232, 0xC23C, 0xC246, 0xC250, 0xC25A, 0xC264 |
| 7-11 | 0x040, 0x048, 0x050, 0x058, 0x060 | TX | RX | labels #251-#255, 0xF1686-0xF16CE | 0xC16C, 0xC174, 0xC17C, 0xC184, 0xC18C |
| 12 | 0x008 (length field 5, DLC 8 configured) | TX (from the segment-0 ROM) | RX (interrupt) | label #256, 0xF16E0 | |

The descriptors are 18 bytes apart here (16 in the master), with the same fields shifted by one byte. Routines: object setup `sub_099CD6` → `sub_09A66A`, reception `fn_099902` → `sub_099882` → `sub_09A79C`, transmission `sub_09A748`.

**Content.** `fn_0A2466` checks the received frames (checksum `sub_0A2354`, the counterpart of the master's `sub_0B1DE0`) and unpacks them into the slave's RAM variables, among them `mrmM_EWUN`, `mrmM_ESTAR`, `fgmFGAKT`, `anmWTF`, `anmVDF`, `anmUBT`, `mrmSTATUS`, `zumAB_NE`/`zumAD_NE`, `fbmBSTZ_UB`, `mrmKM_akt`, `ehmFARS1/2`. The same function packs the reply frames 0x040-0x060 (staging 0xC37C-0xC3A3; checksum in byte 1 of 0x060; the 0x060 slots are dispatched through the jump table at 0xF064E). The reply carries:

- `dzmNakt`, `mrmM_EAKT`, `mrmM_ELLR`, `mrmM_EMOT` in every cycle (frame 0x048). The master has no speed or surge-damper calculation of its own and uses these as `dzmNmit` etc.
- rail pressure `zumP_RAIL` and setpoint `zumPQsoll`, `zumAB_HE`, the idle controller parts `mrmLLRPAnt`/`mrmLLRIAnt`, `mrmN_LLBAS`, the slave sensors `anmLMM1`, `anmLDF1`, `anmLTF1`
- the slave's diagnostic-lamp request `fbmSDIAL`, which the master ORs into its own
- the echo of the master's multiplex counter (byte 0 of 0x060) and of the post-injection handshake value (0x058 bytes 0-1), which the slave applies as `zumAD_NE`

The 0x008 frame is crank-synchronous and sent by the slave ROM; `fn_09695E` only prepares the object pointers (0xF938-0xF93C). It carries the slave's segment counter, its synchronisation status and two 16-bit segment timing values, which the master uses to check that both banks are in step.

The full frame layouts in both directions, the multiplexing, the handshake and the supervision are in [`../DDE41A-RE`](../DDE41A-RE/README.md#canp-protocol).

**No vehicle CAN messages.** The slave calibration contains none of the vehicle CAN identifiers (EGS1 0x43F, ASC1 0x153, DDE1 0x316, INSTR2 0x613), and the master doesn't forward any of them. The transmission's torque reduction reaches the slave only as its result: the master applies `MD_IND_GS` to its quantity demand and sends the resulting `mrmM_EWUN` ("Fahrerwunschmenge nach externem Mengeneingriff") in frame 0x038.

## Checks

- **Interpolator recall:** every curve descriptor passed to `boot_KL_interp` (31 of 31) and every non-null map descriptor passed to `boot_KF_interp` (7 of 7) is in the extracted list. One call passes `R12 = 0`.
- **Map value order (y fastest):** confirmed on the two energising-time maps, which are 3× smoother in this order. The 8×8 rail pressure map also gives monotonic rows. The other KF maps are constant, except 0xF25F2, whose signed timing values make the test inconclusive. Both ECUs use the same boot interpolator, so the format is the same.
- **Master regression:** after the tools were made variant-aware, the master output (`maps.csv`, `labels.csv`) is byte-identical to before.

## Output files

The layout is the same as in the master analysis:

| File | Content |
|---|---|
| [`bin/`](bin) | Program, data and combined 512 KB image |
| [`out/listing.asm`](out/listing.asm) | Annotated disassembly (RAM names, resolved calibration labels, boot services) |
| [`out/functions.csv`](out/functions.csv) | Functions with named reads/writes and chapter guess |
| [`out/maps.md`](out/maps.md) / [`maps.csv`](out/maps.csv) / `maps.json` | 64 curves/maps with axes, values, users |
| [`out/labels.csv`](out/labels.csv) | 539 calibration labels |
| [`out/measurement_table.csv`](out/measurement_table.csv) | 175 measurement IDs → RAM → SGBD names |
| [`out/fault_paths.csv`](out/fault_paths.csv) | 206 fault report call sites |
| [`sgbd/`](sgbd) | `DDE41KL0.prg` decoded: info, 157 jobs, tables |

## Regenerating

The tools live in [`../DDE41A-RE/tools`](../DDE41A-RE/tools) and are shared by both ECUs:

```powershell
cd DDE41A-RE\tools
python run_all.py --variant B
```

## Limitations

These are the same as for the master: the segment-0 code (most likely the C167 internal ROM, see the [master README](../DDE41A-RE/README.md#segment-0-services-internal-rom)) isn't available, heuristic function boundaries, raw values, label names not in the image, fault paths by index only. In addition:

- 76 of the 175 slave RAM variables have no SGBD name.
- No calibration labels from the function description could be matched with confidence: only 4 weak candidates, all on curves.
- CANP: many transferred values have no SGBD name and are identified only by the function that writes them (see the frame tables in [`../DDE41A-RE`](../DDE41A-RE/README.md#canp-protocol)). The 0x008 payload is produced by the slave ROM, so the physical meaning of its two data words (time stamp vs. angle) is inferred from how the master uses them.
