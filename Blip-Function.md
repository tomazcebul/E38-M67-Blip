# Downshift blip for the M67 DDE4.1 with an 8HP and CANTCU (TORQUE_GEARBX approach)

This document specifies a **downshift blip** for the E38 740d (M67D39, DDE4.1 / Bosch EDC15C) after the 5HP30 has been replaced by a ZF 8HP controlled by **CANTCU** (CANformance Race+). The DDE4.1 gets the E65 DDE6.3 blip function: the transmission sends a torque request with "increase / decrease" semantics in a message on ID **0x0B5** (`TORQUE_GEARBX`), and the engine raises its torque to at least that value.

1. [Reference: the DDE6.3 blip function](#1-reference-the-dde63-blip-function)
2. [Starting point: the DDE4.1 today](#2-starting-point-the-dde41-today)
3. [Transport of the 0x0B5 request from CANTCU](#3-transport-of-the-0x0b5-request-from-cantcu)
4. [Function description: blip function for the DDE4.1](#4-function-description-blip-function-for-the-dde41)
5. [Implementation in the DDE41A master firmware](#5-implementation-in-the-dde41a-master-firmware)
6. [Test plan](#6-test-plan), [7. Open points](#7-open-points) and [8. Measurements and the CANformance follow-up](#8-measurements-and-the-canformance-follow-up-parked-until-the-car-is-back)

Status: **design draft**, revised after CANformance's reply (transport via a **User CAN Output** instead of the Default Datastream, engine speed ceiling in the DDE instead of the `TCU RPM Target` check). Sections 1-2 come from the static analysis in this repository. Sections 4-5 are a proposal and haven't been flashed or tested. The patch builder (5.5) assembles and decodes cleanly.

Sources: [DDE63-RE/Function-Description-EGS-Torque-Intervention.md](DDE63-RE/Function-Description-EGS-Torque-Intervention.md), [DDE41A-RE/README.md](DDE41A-RE/README.md), [CANTCU-Installation.md](../E38-8HP-Conversion/CANTCU-Installation.md), [EDC15C function description](../Shared/Documentation/EDC15C-Function-Description/en/03-Fuel-Quantity-Control.md), CANformance wiki ([ECU list](https://wiki.canformance.net/CANTCU/integrations/supportedECUs), [E38/39/46/53/83](https://wiki.canformance.net/CANTCU/integrations/supportedECUs/bmwe394653), [E6/7/8/9x](https://wiki.canformance.net/CANTCU/integrations/supportedECUs/BMWE6789x), [User CAN Outputs](https://wiki.canformance.net/en/CANTCU/software/config/canoutputs), [Race+ configuration](https://wiki.canformance.net/CANTCU/software/race-plus/configuration)).

---

## 1. Reference: the DDE6.3 blip function

The E65 745d (DDE6.3, EDC16CP35) is the model. The full description is in [DDE63-RE/Function-Description-EGS-Torque-Intervention.md](DDE63-RE/Function-Description-EGS-Torque-Intervention.md).

| Step | DDE6.3 |
|---|---|
| Input | `TORQUE_GEARBX` 0x0B5 (10 ms): `TORQ_TAR_EGS` (target, 0.5 Nm), `ST_TORQ_TAR_EGS` (0 none, **1 increase**, 2 decrease, 3 invalid), `TORQ_TAR_ADJR_POS_EGS` (limit for the increase), checksum and alive counter |
| Validity | Checksum and alive correct, signals valid, `TORQ_TAR_ADJR_POS_EGS` ≠ 1000 Nm default |
| Increase request | min(`TORQ_TAR_EGS`, `TORQ_TAR_ADJR_POS_EGS`) |
| Ramp switch | While permitted, the request passes through unchanged and ends abruptly when the EGS drops it. 10 Nm per 20 ms ramp only when the DDE enables or withdraws the function |
| Coordinator | `min(demand + drag, gear limit)` → **`max(·, increase)`** → `min(·, further limit)` → `min(·, reduction)` |
| Calibration in the DDE | None for the blip itself. Amount, duration and which shifts get a blip come from the transmission |

The DDE4.1 version copies this chain: decode `TORQUE_GEARBX` → request evaluation → ramp switch → `max()` in the quantity coordinator, with the reduction keeping priority.

---

## 2. Starting point: the DDE4.1 today

From the master analysis ([DDE41A-RE/README.md](DDE41A-RE/README.md#transmission-egs-torque-intervention)):

| Item | DDE4.1 (`7787316O` / `Y7787646`) |
|---|---|
| Domain | **Fuel quantity** (0.01 mm³/stroke), not torque. Torques are converted with the specific consumption `mroBI_SOLL` (map 0xF21DE) |
| Transmission input | EGS1 0x43F, byte 3 `MD_IND_GS` (0xFF = no intervention) on on-chip CAN object 1 |
| Transmission intervention | `fn_0BB868`, 0x0BC4BA-0x0BC61A: EGS quantity = `MD_IND_GS` × `mroBI_SOLL` / 500 (`CALLS 0:10F2`); result = **min**(driver demand 0xC43C, EGS quantity) → 0xC43A |
| Afterwards | 0x0BC6B2: ASR (min), MSR (max) → 0xC0C2 → `fn_0B1148` → `mrmM_EWUN` |
| Torque increase from the transmission | **None** (§3.1.8.2: the EGS intervention "has a quantity-reducing effect") |
| Slave | Gets `mrmM_EWUN` in CANP frame 0x038 and follows automatically |
| Torque normalisation | `MD_NORM` in DDE2 0x329, multiplex `MUL_COD` = 3 (Nm/16 at 255) |
| Downstream limits | Limitation quantity `mrmM_EBEGR` (smoke, full load, protection, §3.1.9) |

The upshift reduction stays as it is (EGS1 from CANTCU's E38 integration). Only the **increase** path is new.

---

## 3. Transport of the 0x0B5 request from CANTCU

### Bus topology

With Race+, CANTCU uses its buses as follows:

- **CAN1:** the 8HP only (transmission pins 5/6). CAN2 isn't needed.
- **CAN3:** the car (here the former AGS pair to the master DDE, X2412 pins 3/4; see [CANTCU-Installation.md](../E38-8HP-Conversion/CANTCU-Installation.md#engine-control-can-topology)).
- **Shifter:** on CAN1 or CAN3, depending on the model.

The 8HP's own torque and blip requests travel on CAN1 and never reach the DDE. CANTCU translates them into the E38 integration messages (EGS1 0x43F) and a user CAN output, and both are sent on **CAN3**. The DDE4.1 therefore only has to receive the 0x0B5 frame on the bus it already uses for EGS1, which is the C167 on-chip CAN.

If the selected shifter is wired to CAN3, its frames also share the E38 bus. Its IDs must not collide with 0x0B5; check this when choosing the shifter.

### Why not the E6x integration

CANTCU's E6x integration sends the real E65 `TORQUE_GEARBX` 0x0B5, which the DDE6.3 uses for blips. On the E38 it doesn't work, because CANTCU runs one integration on CAN3:

- **No E38 messages.** EGS1 0x43F would disappear, and with it the IKE gear display, the DSC's gearbox information and the existing upshift reduction in the DDE.
- **No engine data for CANTCU.** CANTCU would expect the E65 engine messages (0x0A8/0x0A9/0x0AA torque, speed and pedal; 0x1D0 temperatures). The DDE4.1 sends DDE1/DDE2/DDE4 (0x316/0x329/0x545) instead. Emulating the E65 messages would require a second, much larger DDE patch.

### Recommended: E38 integration + User CAN Output on ID 0x0B5

CANformance's advice is to use a **User CAN Output** and not the Default CAN Datastream (which was the first plan, with Start ID 0x0B4 and frame Base+1 on 0x0B5). Their reply also states that the request logic is already correct for this purpose (visible in any CANTCU log), that the rates are fixed, and that `Engine Torque` is a percentage of `MD_NORM` calculated as in the BMW datasheets.

CANTCU can transmit up to **4 user messages** on CAN3 ([User CAN Outputs](https://wiki.canformance.net/en/CANTCU/software/config/canoutputs)), alongside the integration. Per message: CAN ID, DLC 1-8, cycle (10, 20, 100 or 1000 ms), up to 16 signals. Per signal: variable, start bit, length, byte order, signed, factor and offset, or a static hex value. The design uses one message: **ID 0x0B5, DLC 8, cycle 10 ms** (the E65 rate). Its bytes follow the layout the datastream frame had, so the receive code doesn't depend on which of the two it is:

| Byte (bit) | Signal | Type | Corresponds in the E65 0x0B5 to |
|---|---|---|---|
| 0-1 (0) | Engine Torque | INT16 LE | (not in the E65 0x0B5; engine torque as seen by CANTCU) |
| 2-3 (16) | **Target Torque** | INT16 LE | `TORQ_TAR_EGS` |
| 4 (32) | Shift In Progress | UINT8, 0/1 | (shift window) |
| 5 (40) | **TCU Intervention** | UINT8: 0 none, **1 blip**, 2 shiftcut | `ST_TORQ_TAR_EGS` (0 / 1 increase / 2 decrease) |
| 6 (48) | not used | static `00` | |
| 7 (56) | Blip % | UINT8, % | (fallback amount, see 4.2) |

**Units.** The variable names and units come from the CANTCU Configurator's variable list. `Engine Torque` is % of `MD_NORM`. Factor and offset of each signal are free, so the signals are scaled so that the DDE receives **Nm** (Factor = `MD_NORM` / 100 Nm per % for the echo). The DDE code compares in Nm (4.2, 4.3.1); if the log shows a different unit, only the factor changes.

**Is 0x0B5 free on the E38 vehicle CAN?** Nothing found in the available documents uses it:

- The DDE4.1 master receives 0x43F, 0x615, 0x153, 0x613 and 0x52C and transmits 0x316, 0x329 and 0x545 (CAN objects in the calibration, see [DDE41A-RE/README.md](DDE41A-RE/README.md)).
- The Bosch EDC15C function description (9.2.4, BMW CAN specification 11H Rev. 1.5) lists the messages the DDE exchanges: ASC1 0x153, ASC3 0x1F3, EGS1 0x43F, DDE1 0x316, DDE2 0x329, DDE4 0x545, DDE8 0x338, INSTR2 0x613, TXU1 0x445 and INSTR3 0x615. The DSC's torque requests and its data from the DDE are all in that set. A/C compressor data (`S_KO`, `S_AC`, `LM_KK` in 0x615, `S_KOREL` in 0x316) and the ACC acknowledgements (`Q_ACC_DME` in 0x329, `Q_ACC_BAS` in 0x1F3) are signals inside these frames, not extra IDs.
- The frame catalogue of the E38 750i's M73 powertrain CAN (a separate project) has no 0x0B5 either.
- A scan of the E38 SP-Daten engine control unit data for CAN object records with ID 0x0B5 found none. The SGBDs contain no ID tables.

This isn't proof for traffic that the DDE doesn't see (for example the messages of Active Cruise Control to the DSC, if the car has it), and there are no E38 CAN logs. The baseline log (test plan step 1) has to confirm that 0x0B5 is absent from the stock bus. The ID is free to choose, so a different one works too (the descriptor in 5.3 changes accordingly). One 8-byte frame every 10 ms adds about 2.6 % bus load at 500 kbit/s.

| | E65 `TORQUE_GEARBX` (real) | User output on 0x0B5 |
|---|---|---|
| Rate | 10 ms | 10 ms (selectable, fixed in operation) |
| Torque scaling | 0.5 Nm, 12 bit | free (factor/offset), Nm here |
| Increase / decrease | `ST_TORQ_TAR_EGS` 1 / 2 | `TCU Intervention` 1 / 2 |
| Limit for the increase | `TORQ_TAR_ADJR_POS_EGS` | none → calibration *wrwBLP_MMX* in the DDE |
| Integrity | checksum + alive counter | **none** (CANformance: the user can't add one) → CAN CRC plus end-to-end substitute checks in the DDE (torque echo, EGS1 confirmation, engine speed ceiling; 4.3.1) |

CANformance offered to discuss a separate **add-on integration** (a real, protected 0x0B5 with checksum and alive counter), especially if it is useful for other EDC15 users. That would replace the echo check E1.

**To confirm with a CAN log** (CANTCU E38 integration + user output, manual downshifts):

- `Target Torque` carries the blip target while `TCU Intervention` = 1, rather than for example the pre-shift torque. If not, use `Blip %` (4.2).
- How `Shift In Progress` frames the blip.
- That EGS1 `S_SCHALT` and `GANG_INF` precede the request, and that `MD_IND_GS` stays 0xFF during a downshift blip (CANformance hasn't answered this yet).
- Which variables exist for the user output, and what the frame contains while CANTCU or the transmission is in a fault or limp state.
- `MD_NORM` from DDE2 0x329 (`MUL_COD` = 3) and the exact definition of `Engine Torque` (with or without friction torque).
- 0x0B5 absent from the stock bus before the output is enabled, and no DSC/IKE faults with the extra frame on the bus.

### CANTCU configuration for the M67

The blip only fires on downshifts that CANTCU decides to make, so the CANTCU settings define the blip range. All of them are engine-specific, and the stock values are for petrol engines:

- **RPM Limits** (Race+ configuration, Transmission): `Idle RPM`, `Max RPM` and `Downshift RPM` (screenshot defaults: 800 / 5000 / 2000). Set them for the M67 and to the same values used when Race+ was flashed with the 8HP TCM tool. Wrong values give unexpected shifting.
- **Auto-upshift in Manual:** the rpm (default 6800) is configurable and has to be set for the diesel.
- **Shift maps** (Drive and Sport), rpm over pedal position. The maps aren't set up automatically. *Generate* creates a complete starting map from *Minimum shift RPM* (upshift at 0 % pedal; defaults 1500 Drive / 2000 Sport) and *Maximum shift RPM* (upshift at 100 % pedal and kickdown; defaults 6500 / 7000). Downshift points are calculated from the gear ratios. Then tune by hand or with Autolearn. A red cell pair means an upshift and downshift point too close together for that gear pair and pedal position (the gearbox would hunt): raise the upshift or lower the downshift rpm until nothing is red. Holding the Spacebar shows the engine speed after the shift.
- **Predictive downshifts** (Sport): *Maximum RPM increase* (35 %) limits how far a predicted downshift raises the engine speed.

The engine speed after a downshift (the Spacebar view) is what the blip has to reach, so tuning the maps also changes the blip size. **`wrwBLP_NMX` is derived from the final maps:** highest engine speed after any permitted downshift plus a margin, but below the governed engine speed of the M67 and not below `Max RPM`. CANTCU's `Max RPM` limits the shift decision only. It isn't a limit on the request and doesn't replace the DDE ceiling (E3, 4.3.1).

---

## 4. Function description: blip function for the DDE4.1

Written like §3.1.8 of the EDC15C function description. New messages and labels are **working names** (prefix `w`). The CAN signal names follow the E65 0x0B5 names, mapped onto the user output bytes.

### 4.1 Overview

The external quantity intervention (§3.1.8) gets an additional, **quantity-increasing** EGS intervention *wroM_EBLIP*. It is inserted after the minimum selection with the EGS1 quantity and before the ASR intervention:

```text
mroM_EXGS   = MD_IND_GS × mroBI_SOLL                (existing, EGS1 upshift reduction)
x           = MIN(driver demand, mroM_EXGS)          (existing, 0xC43A)
x           = MAX(x, wroM_EBLIP)                     NEW: TORQUE_GEARBX increase (blip)
x           = MIN(x, mroM_EASR)                      (existing, ASR keeps priority)
...         = MAX(x, mroM_EMSR) -> mrmM_EWUN          (existing, to slave in CANP 0x038)
```

This is the DDE6.3 order (`min(gear limit)` → `max(increase)` → further limits) in the quantity domain. The reduction gets priority by suppressing the blip while EGS1 reduces (4.3, condition 4).

```mermaid
flowchart LR
    RX[TORQUE_GEARBX 0x0B5<br/>CANTCU user output] --> EV{Request evaluation<br/>ST_TORQ_TAR = 1?}
    EV -->|valid| CV[TORQ_TAR Nm → MD scale → quantity<br/>MIN wrwBLP_MMX]
    EV -->|not valid / ended| NR[0 = no request]
    CV & NR --> RS[Ramp switch<br/>wrwBLP_RAMP]
    RS --> QB[wroM_EBLIP]
    D[driver demand 0xC43C] --> M1[MIN with EGS1 quantity<br/>existing]
    M1 --> M2[MAX with wroM_EBLIP]
    QB --> M2
    M2 --> ASR[MIN ASR / MAX MSR<br/>existing] --> EW[mrmM_EWUN → slave 0x038]
```

Figure 4-1: WBLIP01, `TORQUE_GEARBX` increase intervention in the external quantity intervention

### 4.2 Receiving TORQUE_GEARBX

| CAN message: TORQUE_GEARBX (CANTCU user output) | | Identifier: 0B5H | | | |
|---|---|---|---|---|---|
| Signal (working name) | User output signal | Bit addr. | Bit count | Default | Message |
| `TORQ_ENG_TCU` | Engine Torque (Nm, scaled by the output factor) | 0 | 16 | 0 | *wroBLP_MENG* |
| `TORQ_TAR_EGS` | Target Torque | 16 | 16 | 0 | *wroBLP_MTAR* (Nm) |
| `ST_SHIFT` | Shift In Progress | 32 | 8 | 0 | *wroBLP_SHFT* |
| `ST_TORQ_TAR_EGS` | TCU Intervention | 40 | 8 | 0 | *wroBLP_ST* |
| (not used) | Shiftcut % | 48 | 8 | 0 | |
| `BLIP_PCT` | Blip % | 56 | 8 | 0 | *wroBLP_PCT* |

Received on on-chip CAN object 9 with the same receive handler as EGS1 (`sub_097E8E`). After *wcwBLP_TOUT* task cycles without a new message, the buffer is filled with the default data (all 0 = no request) and status bit 2 is set.

**Request torque.** The requested torque *wroBLP_MREQ* (Nm) is:

- *wcwBLP_SRC* = 0: *wroBLP_MTAR* (Target Torque),
- *wcwBLP_SRC* = 1: *wroBLP_PCT* × *wrwBLP_MPCT* / 100 (Blip % of a calibrated torque), as a fallback if the log shows that Target Torque doesn't carry the blip target.

**Torque to quantity.** The DDE4.1 computes intervention quantities from the 8-bit torque scale of `MD_IND_GS` (% of `MD_NORM`, 255 = 16 × `MD_NORM` Nm). The request is first converted to that scale and then with the existing conversion:

*wroBLP_MDR* = MIN(*wroBLP_MREQ* × 255 / *wrwBLP_MDN*, 254), with *wrwBLP_MDN* = 16 × `MD_NORM` in Nm

*wroM_EBLPR* = MIN(*wroBLP_MDR* × `mroBI_SOLL` / 500, *wrwBLP_MMX*)

### 4.3 Request evaluation

Like the ASR/MSR intervention (§3.1.8.3/3.1.8.4), the increase intervention is only recognised as valid if all of these hold. Otherwise *wroM_EBLIP* goes to the neutral value 0.

1. The function is enabled (*wcwFUN_BLP* = 1).
2. **Message present:** the receive status shows no default data (status bit 2 = 0).
3. **Request:** *wroBLP_ST* = 1 (increase; 2 = decrease is ignored because the reduction comes via EGS1), *wroBLP_MREQ* > 0 and, if *wcwBLP_SHFT* = 1, *wroBLP_SHFT* = 1.
4. **Reduction has priority:** EGS1 isn't missing (*fbeEEGS_F* = 0) and isn't reducing (`MD_IND_GS` = 0xFF).
5. **Operating window:** `dzmNmit` ≥ *wrwBLP_NMN*, `anmWTF` ≥ *wrwBLP_TMN*, `fgmFGAKT` ≥ *wrwBLP_VMN*. The upper engine speed limit *wrwBLP_NMX* is the ceiling E3 (4.3.1).
6. **Maximum duration** (last-resort protection against a stuck request): a counter *wroBLP_T* runs while the request is present. If it reaches *wrwBLP_TMX*, the request is ignored until *wroBLP_ST* has been 0 at least once (status 4). After *wrwBLP_LOCK* such events in one driving cycle, the function stays off until terminal 15 off (status 8).
7. **End-to-end substitute checks** E1-E3 (4.3.1) pass.

#### 4.3.1 End-to-end substitute for the missing checksum and alive counter

The E65 protects 0x0B5 with a checksum and an alive counter. It helps to separate the faults these are meant to catch:

| Fault | Covered by |
|---|---|
| Bit errors on the wire | **CAN controller CRC-15**, already in hardware; corrupted frames are discarded |
| Frame from the wrong sender | ID 0x0B5 isn't used by any other node on the E38 bus |
| Message missing | Receive timeout (condition 2) |
| **Sender keeps sending a frozen or stale frame** | Alive counter on the E65, **E1/E2 here** |
| **Sender sends a wrong request** (software or configuration fault) | Checksum and plausibility on the E65, **E2/E3 here** |

The checks below use data that CANTCU already receives from the DDE or the DDE receives from EGS1. All of them must pass before a request is accepted. A failure that persists for *wrwBLP_EDEB* task cycles counts as an integrity error. *wrwBLP_EMX* errors in one driving cycle lock the function until terminal 15 off.

**E1: torque echo in the request frame (freshness of 0x0B5).** The frame carries `Engine Torque` next to the request. CANformance calculates it as a percentage of `MD_NORM`, as in the BMW datasheets (DDE1 `MD_IND_NE`, possibly minus `MD_REIB`; to be confirmed by log). The DDE computes the same value from its DDE1 transmit buffer and checks:

|`Engine Torque` − own torque| ≤ *wrwBLP_DME*, after a PT1 filter (*wrwBLP_EPT1*) for the CANTCU delay

The engine torque rises during a blip, so a frozen 0x0B5 frame stops matching. This makes the request frame self-checking. The first design also echoed the engine speed in a second frame; with one user message that isn't available. A second user output could carry it if CANTCU has a suitable variable (section 7).

**E2: confirmation by EGS1 (second, independent message).** The request must agree with the E38 integration message EGS1 0x43F, which CANTCU builds by a separate path:

- EGS1 `S_SCHALT` (shift active) = 1;
- EGS1 `GANG_INF` (target gear) is lower than the gear latched before the shift (downshift);
- EGS1 `MD_IND_GS` = 0xFF (no reduction, already condition 4).

The request must also **start** (rising edge of `TCU Intervention` = 1) within *wrwBLP_TARM* after `S_SCHALT` rises. The blip ends at the latest when `S_SCHALT` falls, whatever the user output says. A stuck 0x0B5 frame alone therefore can't create a blip or keep one running.

**E3: engine speed ceiling.** As soon as `dzmNmit` ≥ *wrwBLP_NMX*, *wroM_EBLIP* is set to 0 immediately (status 128), and no blip starts at or above it. This is a fixed calibration that doesn't depend on CANTCU. *wrwBLP_NMX* is derived from CANTCU's `Max RPM` and the tuned shift maps (3, "CANTCU configuration for the M67"). CANTCU's own `Max RPM` already keeps its downshift decisions inside the engine's range, so the transmission's target-gear speed (`TCU RPM Target`) isn't needed by the DDE.

Even with a completely wrong torque request, the engine can't be raised above *wrwBLP_NMX*. Below it, the blip is limited only by *wrwBLP_MMX* and *wrwBLP_TMX*, and the ceiling doesn't follow the target gear speed of the individual shift.

All three checks use only 0x0B5 and the existing EGS1 object, so only one additional on-chip CAN object is needed (5.1, 5.3).

With these checks, a single fault in CANTCU, whether a frozen frame, a wrong request or a lost message, either isn't accepted or is limited to the engine speed ceiling, the maximum quantity and the maximum duration.

### 4.4 Ramp switch

As in the DDE6.3 (`fn_45AD50`, FId 0xC7):

- **While permitted** (conditions 1, 2, 4, 5 met): *wroM_EBLIP* = *wroM_EBLPR* if a request is present (condition 3), with no ramp or filter. The shape of the blip comes entirely from CANTCU.
- **When the request ends** (*wroBLP_ST* ≠ 1): *wroM_EBLIP* = 0 immediately (abrupt end).
- **When the permission is withdrawn during a request** (timeout, reduction from EGS1, operating window left, maximum duration): *wroM_EBLIP* ramps to 0 with *wrwBLP_RAMP* per call (status 2).

### 4.5 Interaction with other functions

- **ASR/MSR:** the blip comes before the ASR minimum, so traction control can always cut it. MSR stays a `max()` after it.
- **Limitation quantity:** `mrmM_EBEGR` (smoke, full load, turbocharger protection) applies downstream and also limits the blip.
- **Overrun fuel cut-off (§3.1.4):** the blip raises the desired quantity above 0, so the cut-off logic sees a demand. To verify on the car.
- **Active surge damper (§3.1.12):** during shifts (`S_SCHALT` in EGS1) the ARD uses its shift parameter set `mrwARDS_I`.
- **Torque feedback:** DDE1 `MD_IND_NE` (`mroMD_SOLL`) contains the result after the interventions, so CANTCU sees the torque rise.
- **Slave:** unchanged; it receives the raised `mrmM_EWUN` in CANP 0x038.

### 4.6 Status

| wroBLPSTAT | Meaning |
|---|---|
| 1 | Increase intervention active (*wroM_EBLIP* > 0) |
| 2 | Ramp *wrwBLP_RAMP* active (permission withdrawn) |
| 4 | Maximum duration *wrwBLP_TMX* reached, waiting for the request to drop |
| 8 | Function locked until terminal 15 off (*wrwBLP_LOCK* reached) |
| 16 | Request present but outside the operating window, or EGS1 reducing |
| 32 | `TORQUE_GEARBX` missing (default data) |
| 64 | End-to-end check failed (E1, E2); lock after *wrwBLP_EMX* errors |
| 128 | Engine speed ceiling reached (E3), blip cut |

### 4.7 Messages and parameters

**Inputs:** `dzmNmit` (0xC0A8), `anmWTF` (0xC086), `fgmFGAKT` (0xC0A0), `mroBI_SOLL` (0xC40A, task-local in `fn_0BB868`), `MD_IND_GS` (EGS1 copy via pointer 0xD656), quantity after the EGS minimum (0xC43A).

**New RAM:** *wroBLP_MTAR*, *wroBLP_ST*, *wroBLP_SHFT*, *wroBLP_MREQ*, *wroBLP_MDR*, *wroM_EBLPR*, *wroM_EBLIP*, *wroBLP_T*, *wroBLP_NLOCK*, *wroBLPSTAT*.

**New calibration** (block at 0xF7880, section 5.4):

| Offset | Label | Meaning | Unit | Start value |
|---|---|---|---|---|
| +0x00 | *wcwFUN_BLP* | Function switch | 0/1 | 0 (off until tested) |
| +0x02 | *wrwBLP_NMN* | Minimum engine speed | rpm | 900 |
| +0x04 | *wrwBLP_NMX* | Engine speed ceiling (E3), derived from `Max RPM` and the tuned shift maps | rpm | 3800 (placeholder) |
| +0x06 | *wrwBLP_TMN* | Minimum coolant temperature | `anmWTF` raw | ≙ 60 °C |
| +0x08 | *wrwBLP_VMN* | Minimum vehicle speed | 0.01 km/h | 500 |
| +0x0A | *wrwBLP_MMX* | Maximum blip quantity | 0.01 mm³ | 3000 (start low) |
| +0x0C | *wrwBLP_TMX* | Maximum blip duration | task cycles | ≙ 600 ms |
| +0x0E | *wrwBLP_RAMP* | Ramp step when withdrawn | 0.01 mm³ per call | 200 (as *mrwEGSRAMP*) |
| +0x10 | *wcwBLP_SHFT* | Require Shift In Progress | 0/1 | 1 |
| +0x12 | *wrwBLP_MDN* | 16 × `MD_NORM` | Nm | from DDE2 log |
| +0x14 | *wcwBLP_SRC* | Torque source (0 Target Torque, 1 Blip %) | | 0 |
| +0x16 | *wrwBLP_MPCT* | Torque at Blip % = 100 | Nm | 300 |
| +0x18 | *wrwBLP_LOCK* | Duration events until lock | | 3 |
| +0x1A | *wrwBLP_DME* | E1: max. deviation `Engine Torque` echo vs own torque | Nm | 80 |
| +0x1C | *wrwBLP_EPT1* | E1: PT1 factor for the own torque (CANTCU delay) | 1/256 | from log |
| +0x1E | *wrwBLP_TARM* | E2: window after `S_SCHALT` rising in which the request may start | task cycles | ≙ 300 ms |
| +0x20 | *wrwBLP_EDEB* | Debounce of E1/E2 failures | task cycles | 3 |
| +0x22 | *wrwBLP_EMX* | Integrity errors until lock | | 3 |
| +0x80 | *wcwBLP_CAN* | Receive descriptor (5.3) | | |

---

## 5. Implementation in the DDE41A master firmware

Only the **master** (`7787316O.0PA` program + `Y7787646.0DA` data) is changed. The slave stays stock.

### 5.1 Free resources

| Resource | Where | Evidence |
|---|---|---|
| Program code | **0x0C0000-0x0DFEFF** (128 KB) | 0xFF in the `.0PA` and the full flash read; last application byte at 0x0BD15A. Covered by the program file and erased by `FLASH_LOESCHEN` |
| Calibration | **0x0F7846-0x0F7FFF** (1978 bytes, C3 filler) | After the last label; reachable as 16-bit 0x7846-0x7FFF through DPP1 (0x3D) |
| RAM | **0xE780-0xE7DF** (XRAM, proposal) | No direct or immediate reference in the application. The top-sector flash drivers use 0xE000-0xE5FF only in programming mode. Not provable statically (segment-0 ROM and stack are invisible) → bench check (5.7) |
| CAN | On-chip CAN **object 9** (0xEF90): 0x0B5 (objects 10 and 11 stay free) | Objects 1-8 used; `sub_097BCA` resets all 15 |

### 5.2 Hooks

Three 4-byte `CALLS` replacements. In each case the replaced instruction is executed inside the patch.

| # | Address | Original | Replaced by | Purpose |
|---|---|---|---|---|
| H1 | 0x099858 (`sub_099802`) | `DA 09 E0 7B` `CALLS 0x097BE0` | `DA 0C 00 00` `CALLS 0x0C0000` | Configure object 9 (0x0B5), then `sub_097BE0` |
| H2 | 0x097FA8 (`fn_097F10`) | `DA 09 8E 7E` `CALLS 0x097E8E` | `DA 0C 00 01` `CALLS 0x0C0100` | Receive object 5 as before, then object 9 |
| H3 | 0x0BC61C (`fn_0BB868`) | `F3 F8 80 C4` `MOVB RL4, 0xC480` | `DA 0C 00 02` `CALLS 0x0C0200` | Blip function after the EGS minimum, then `MOVB RL4, 0xC480` |

Register rules observed in the original code:

- In `fn_0BB868`, `R0` is a frame pointer (`[R0+#n]`) and must not change.
- After H3 the code reloads R1-R5 itself.
- After H2 the caller stores `RL7`/`R9` (object 5 state), so the patch must return them unchanged.
- `sub_099802` uses `R0` as the descriptor argument for `sub_097C14` and doesn't need it after H1.

### 5.3 CAN receive descriptor

At 0xF7900 (16-bit 0x7900, DPP1), same 16-byte layout as the EGS1 descriptor at 0xF1F80 (`01 32 01 00 06 00 00 FF 00 00 00 10 08 87 E0 80`):

| Offset | Value | Meaning |
|---|---|---|
| +0x00 | `01` | Reload of the poll counter (`RL7`) |
| +0x01 | *wcwBLP_TOUT* | Timeout in task cycles. Set to about 3 periods of the 10 ms user output (30 ms) once the task period is known; EGS1 uses 0x32 |
| +0x02 | `01` | Use default data on timeout |
| +0x03-0x0A | `00 00 00 00 00 00 00 00` | Default data: no torque, no shift, intervention 0 |
| +0x0B | `90` | Object 9 (0xEF90) |
| +0x0C | `08` | Length |
| +0x0D-0x0E | `16 A0` | Arbitration 0x0B5 << 5 (for another ID: ID << 5) |
| +0x0F | `80` | DLC 8, receive |

There is no second or third descriptor: the end-to-end checks need only this frame and EGS1.

### 5.4 New code (C167 assembly, draft)

Conventions as in the listing: DPP0 = 0x3C (0xF0000), DPP1 = 0x3D (0xF4000), DPP3 = RAM/SFR. Calibration block `BLP_CAL` at 16-bit 0x7880 (→ 0xF7880). RAM at 0xE780. `CALLS 0:10F2` is the multiply/divide routine of the EGS block (R4 = R12 × R13 / R14).

```asm
; ---------------- RAM (XRAM, proposal) ----------------
BLP_RXBUF   EQU 0E780h   ; 9 bytes: user output 0x0B5 + status (filled by sub_097E8E)
                         ;  +0 Engine Torque  +2 Target Torque  +4 Shift  +5 Intervention
                         ;  +6 Shiftcut %     +7 Blip %         +8 receive status
BLP_RXCNT   EQU 0E78Ah   ; byte: poll counter (RL7)
BLP_RXTIM   EQU 0E78Ch   ; word: receive time stamp (R9)
BLP_STAT    EQU 0E78Eh   ; byte: wroBLPSTAT
BLP_NLOCK   EQU 0E78Fh   ; byte: duration events in this driving cycle
BLP_QREQ    EQU 0E790h   ; word: wroM_EBLPR
BLP_Q       EQU 0E792h   ; word: wroM_EBLIP
BLP_T       EQU 0E794h   ; word: wroBLP_T
BLP_TOLOCK  EQU 0E796h   ; byte: 1 = duration exceeded, wait for request drop
BLP_INIT    EQU 0E798h   ; word: 0x5AA5 when initialised

; ---------------- calibration (DPP1) ----------------
BLP_CAL     EQU 07880h   ; layout in 4.7
BLP_DESC    EQU 07900h   ; CAN descriptor (5.3)

; ===== H1: 0x0C0000, end of sub_099802 (CAN init) =====
blp_can_init:
        MOV     R0, #BLP_DESC
        CALLS   09h, 7C14h           ; configure object 9 like objects 1-8
        MOVB    RL1, BLP_DESC        ; poll counter reload
        MOVB    BLP_RXCNT, RL1
        MOV     R1, 0F940h           ; time base, as in loc_097E20
        MOV     BLP_RXTIM, R1
        MOV     BLP_T, ZEROS
        MOV     BLP_Q, ZEROS
        MOVB    BLP_TOLOCK, ZEROS
        MOVB    BLP_NLOCK, ZEROS     ; init runs after power-up -> per driving cycle
        MOV     R1, #5AA5h
        MOV     BLP_INIT, R1
        CALLS   09h, 7BE0h           ; original instruction
        RETS

; ===== H2: 0x0C0040, fn_097F10 (receive task) =====
blp_can_rx:
        CALLS   09h, 7E8Eh           ; object 5 (original)
        PUSH    R7
        PUSH    R9
        MOV     R4, BLP_INIT
        CMP     R4, #5AA5h
        JMPR    cc_NZ, rx_done
        MOV     R6, #BLP_DESC
        MOV     R1, #BLP_RXBUF
        MOVB    RL7, BLP_RXCNT
        MOV     R9, BLP_RXTIM
        CALLS   09h, 7E8Eh           ; object 9 (0x0B5), same handler as EGS1
        MOVB    BLP_RXCNT, RL7
        MOV     BLP_RXTIM, R9
rx_done:
        POP     R9
        POP     R7
        RETS

; ===== H3: 0x0C0100, fn_0BB868 at 0x0BC61C =====
; in : 0xC43A = quantity after the EGS1 minimum, 0xC40A = mroBI_SOLL
; out: 0xC43A = MAX(0xC43A, wroM_EBLIP)
blp_main:
        PUSH    R6
        PUSH    R7
        MOVB    RL7, #0                  ; new status
        MOV     R4, BLP_INIT
        CMP     R4, #5AA5h
        JMPR    cc_NZ, blp_off
        MOV     R4, BLP_CAL              ; 1. wcwFUN_BLP
        CMP     R4, #0
        JMPR    cc_Z, blp_off
        MOVB    RL4, BLP_NLOCK           ;    driving-cycle lock
        CMPB    RL4, BLP_CAL+18h
        JMPR    cc_UGE, blp_locked
        ; --- 2. message present ---
        MOVB    RL4, BLP_RXBUF+8
        JB      R4.2, blp_missing
        ; --- 3. request ---
        MOVB    RL4, BLP_RXBUF+5         ; ST_TORQ_TAR_EGS (TCU Intervention)
        CMPB    RL4, #1
        JMPR    cc_NZ, blp_norq
        MOV     R4, BLP_CAL+10h          ; wcwBLP_SHFT
        CMP     R4, #0
        JMPR    cc_Z, blp_shft_ok
        MOVB    RL4, BLP_RXBUF+4         ; Shift In Progress
        CMPB    RL4, #1
        JMPR    cc_NZ, blp_norq
blp_shft_ok:
        MOV     R4, BLP_CAL+14h          ; wcwBLP_SRC
        CMP     R4, #0
        JMPR    cc_NZ, blp_src_pct
        MOV     R12, BLP_RXBUF+2         ; Target Torque [Nm]
        JMPR    cc_UC, blp_have_tq
blp_src_pct:
        MOVB    RL4, BLP_RXBUF+7         ; Blip %
        MOVBZ   R12, RL4
        MOV     R13, BLP_CAL+16h         ; wrwBLP_MPCT
        MOV     R14, #100
        CALLS   00h, 10F2h
        MOV     R12, R4
blp_have_tq:
        CMP     R12, #0
        JMPR    cc_SLE, blp_norq
        ; --- 4. EGS1 reduction has priority ---
        MOV     R5, 0D656h               ; pointer to the EGS1 copy (fn_0BB608)
        MOVB    RL5, [R5+#3]             ; MD_IND_GS
        CMPB    RL5, #0FFh
        JMPR    cc_NZ, blp_window
        ; --- 5. operating window ---
        MOV     R5, 0C0A8h               ; dzmNmit
        CMP     R5, BLP_CAL+2
        JMPR    cc_ULT, blp_window
        MOV     R5, 0C086h               ; anmWTF
        CMP     R5, BLP_CAL+6
        JMPR    cc_SLT, blp_window
        MOV     R5, 0C0A0h               ; fgmFGAKT
        CMP     R5, BLP_CAL+8
        JMPR    cc_ULT, blp_window
        ; --- 6. maximum duration ---
        MOVB    RL4, BLP_TOLOCK
        CMPB    RL4, #0
        JMPR    cc_NZ, blp_tmo_wait
        MOV     R5, BLP_T
        CMP     R5, BLP_CAL+0Ch
        JMPR    cc_UGE, blp_timeout
        ADD     R5, #1
        MOV     BLP_T, R5
        ; --- torque [Nm] -> MD scale -> quantity ---
        MOV     R13, #255
        MOV     R14, BLP_CAL+12h         ; wrwBLP_MDN = 16 x MD_NORM
        CALLS   00h, 10F2h               ; R4 = Nm x 255 / MDN
        CMP     R4, #254
        JMPR    cc_ULE, blp_md_ok
        MOV     R4, #254
blp_md_ok:
        MOV     R12, R4
        MOV     R13, 0C40Ah              ; mroBI_SOLL (task-local, valid here)
        MOV     R14, #01F4h              ; 500, as in the EGS1 conversion
        CALLS   00h, 10F2h
        CMP     R4, BLP_CAL+0Ah          ; wrwBLP_MMX
        JMPR    cc_SLE, blp_q_ok
        MOV     R4, BLP_CAL+0Ah
blp_q_ok:
        MOV     BLP_QREQ, R4
        MOV     BLP_Q, R4                ; permitted: pass through, no ramp
        MOVB    RL7, #1
        JMPR    cc_UC, blp_apply

blp_norq:                                ; request ended -> abrupt end
        MOV     BLP_T, ZEROS
        MOVB    BLP_TOLOCK, ZEROS
        MOV     BLP_Q, ZEROS
        JMPR    cc_UC, blp_apply
blp_timeout:
        MOVB    RL4, #1
        MOVB    BLP_TOLOCK, RL4
        MOVB    RL4, BLP_NLOCK
        ADDB    RL4, #1
        MOVB    BLP_NLOCK, RL4
blp_tmo_wait:
        MOVB    RL7, #4
        JMPR    cc_UC, blp_withdraw
blp_locked:
        MOVB    RL7, #8
        JMPR    cc_UC, blp_withdraw
blp_missing:
        MOVB    RL7, #32
        JMPR    cc_UC, blp_withdraw
blp_window:
        MOVB    RL7, #16
blp_withdraw:                            ; permission withdrawn -> ramp to 0
        MOV     R4, BLP_Q
        SUB     R4, BLP_CAL+0Eh          ; wrwBLP_RAMP
        JMPR    cc_SGT, blp_ramp_ok
        MOV     R4, #0
blp_ramp_ok:
        MOV     BLP_Q, R4
        CMP     R4, #0
        JMPR    cc_Z, blp_apply
        ORB     RL7, #2
        JMPR    cc_UC, blp_apply
blp_off:
        MOV     BLP_Q, ZEROS
blp_apply:
        MOVB    BLP_STAT, RL7
        MOV     R4, BLP_Q
        CMP     R4, 0C43Ah
        JMPR    cc_SLE, blp_exit
        MOV     0C43Ah, R4               ; MAX(quantity after EGS1 minimum, blip)
blp_exit:
        POP     R7
        POP     R6
        MOVB    RL4, 0C480h              ; original instruction at 0x0BC61C
        RETS
```

Notes on the draft:

- The calibration comparisons use the raw units of the target variables: rpm for `dzmNmit`, the `anmWTF` raw scale, 0.01 km/h for `fgmFGAKT` (cf. *mrwV_ANFAH* = 4500 = 45 km/h) and 0.01 mm³ for quantities.
- `CALLS 0:10F2` is used with R12 = torque byte, R13 = `mroBI_SOLL`, R14 = 500 in the original. Its signedness and overflow behaviour are inferred from that use; the Nm → MD-scale call must be checked with real values (positive torques only, R12 ≤ 1000 Nm).
- The task period of `fn_0BB868` sets the time base for *wrwBLP_TMX*, *wrwBLP_RAMP* and *wcwBLP_TOUT*. It must be measured (5.7).
- If the decrease part of 0x0B5 should also be used (DDE6.3 `ST_TORQ_TAR_EGS` = 2), it can be added as a `MIN()` in the same hook. It isn't needed while EGS1 carries the reduction.

#### End-to-end checks E1-E3 (fragment)

These checks run in `blp_main` after condition 5 and before the quantity calculation. A failure goes to `blp_e2e_fail`, which debounces with *wrwBLP_EDEB*, counts errors against *wrwBLP_EMX* and continues at `blp_withdraw` with status 64. In the code, the EGS1 shift state (E2, part 1) is evaluated first because it also latches the gear while no shift is running.

```asm
BLP_GLATCH  EQU 0E7C0h   ; byte: EGS1 gear latched before the shift
BLP_SPREV   EQU 0E7C1h   ; byte: previous EGS1 S_SCHALT
BLP_ARM     EQU 0E7C2h   ; word: cycles since S_SCHALT rising
BLP_STPREV  EQU 0E7C4h   ; byte: previous TCU Intervention
BLP_ARMED   EQU 0E7C5h   ; byte: request started inside the arming window
BLP_MOWN    EQU 0E7C6h   ; word: own torque, PT1-filtered [Nm]
BLP_EDEB    EQU 0E7C8h   ; byte: debounce counter
BLP_EERR    EQU 0E7C9h   ; byte: integrity errors in this driving cycle

; ---- E2: EGS1 shift state (EGS1 copy via pointer 0xD656, valid inside fn_0BB868) ----
        MOV     R5, 0D656h
        MOVB    RL4, [R5]                ; EGS1 byte 0
        MOVB    RL3, RL4
        ANDB    RL3, #07h                ; GANG_INF
        JB      R4.3, e3_shift           ; S_SCHALT = 1
        MOVB    BLP_GLATCH, RL3          ; no shift: latch current gear
        MOVB    BLP_SPREV, ZEROS
        MOVB    BLP_ARMED, ZEROS
        JMPR    cc_UC, blp_norq          ; no shift -> no blip, whatever 0x0B5 says
e3_shift:
        MOVB    RL2, BLP_SPREV
        CMPB    RL2, #0
        JMPR    cc_NZ, e3_running
        MOV     BLP_ARM, ZEROS           ; S_SCHALT rising: open arming window
        MOVB    RL2, #1
        MOVB    BLP_SPREV, RL2
e3_running:
        CMPB    RL3, BLP_GLATCH          ; target gear must be lower (downshift)
        JMPR    cc_UGE, blp_e2e_fail
        MOV     R4, BLP_ARM
        ADD     R4, #1
        MOV     BLP_ARM, R4
        MOVB    RL2, BLP_STPREV          ; rising edge of TCU Intervention = 1?
        MOVB    RL1, BLP_RXBUF+5
        MOVB    BLP_STPREV, RL1
        CMPB    RL2, #1
        JMPR    cc_Z, e3_armed_chk       ; request already running
        CMP     R4, BLP_CAL+1Eh          ; edge must come within wrwBLP_TARM
        JMPR    cc_UGT, blp_e2e_fail
        MOVB    RL2, #1
        MOVB    BLP_ARMED, RL2
e3_armed_chk:
        MOVB    RL2, BLP_ARMED
        CMPB    RL2, #0
        JMPR    cc_Z, blp_e2e_fail

; ---- E1: torque echo in the request frame 0x0B5 ----
        MOVB    RL4, 0C125h              ; DDE1 byte 1 MD_IND_NE (transmit buffer 0xC124)
        MOVBZ   R12, RL4
        MOV     R13, BLP_CAL+12h         ; wrwBLP_MDN = 16 x MD_NORM
        MOV     R14, #255
        CALLS   00h, 10F2h               ; own torque [Nm]
        MOV     R5, BLP_MOWN             ; PT1: m += (new - m) x EPT1 / 256
        SUB     R4, R5
        MOV     R12, R4
        MOV     R13, BLP_CAL+1Ch         ; wrwBLP_EPT1
        MOV     R14, #256
        CALLS   00h, 10F2h               ; (signed use to be checked, see notes)
        ADD     R4, BLP_MOWN
        MOV     BLP_MOWN, R4
        SUB     R4, BLP_RXBUF            ; - Engine Torque echo (0x0B5 bytes 0-1)
        JMPR    cc_NN, e2_abs
        NEG     R4
e2_abs:
        CMP     R4, BLP_CAL+1Ah          ; wrwBLP_DME
        JMPR    cc_UGT, blp_e2e_fail
        MOVB    BLP_EDEB, ZEROS

; ---- E3: engine speed ceiling ----
        MOV     R4, 0C0A8h               ; dzmNmit
        CMP     R4, BLP_CAL+4            ; wrwBLP_NMX
        JMPR    cc_ULT, e3_ok
        MOVB    RL7, #128                ; ceiling reached: cut immediately
        MOV     BLP_Q, ZEROS
        JMPR    cc_UC, blp_apply
e3_ok:
        ; continue with condition 6 (maximum duration) and the quantity calculation
```

The E1 own-torque formula (`MD_IND_NE` only, or minus `MD_REIB`) has to match what CANTCU reports as `Engine Torque`, which CANformance defines as a percentage of `MD_NORM`. Align it with the log before setting *wrwBLP_DME* tight. The PT1 step uses `CALLS 0:10F2` with a possibly negative difference; if the routine is unsigned, replace it with `MUL`/`DIV` instructions.

### 5.5 Patched images (build)

[`DDE41A-RE/tools/blip_patch.py`](DDE41A-RE/tools/blip_patch.py) builds the patch from the stock binaries in `DDE41A-RE/bin` and writes **copies** to [`DDE41A-RE/patch/`](DDE41A-RE/patch). The SP-Daten files and `DDE41A-RE/bin` aren't modified.

```powershell
cd DDE41A-RE\tools
python blip_patch.py
```

| Output | Content |
|---|---|
| `7787316O_program_blip.bin` | Program 0x080000-0x0EFFFF with hooks H1-H3 and the code at 0x0C0000-0x0C04E7 |
| `Y7787646_data_blip.bin` | Data 0x0F0000-0x0FFFFF with the calibration block 0x0F7880-0x0F78A3 and the descriptor 0x0F7900-0x0F790F |
| `DDE41A_O_full_80000_blip.bin` | Combined 512 KB image 0x080000-0x0FFFFF; top sector 0x0FC000-0x0FFFFF unchanged from the stock flash read |
| `blip_patch.lst` | Hooks, calibration values, descriptors and the decoded code |

How the build works:

- **Assembler.** A minimal two-pass encoder for the C167 instructions used. It has no external dependencies.
- **Branches.** Conditional branches use `JMPA` (absolute within segment 0x0C), so there are no relative-range limits.
- **Arithmetic.** The code computes with the native `MULU`/`DIVLU`/`ASHR` instructions instead of `CALLS 0:10F2`, whose signedness is unknown.
- **Entry points.** H1 at 0x0C0000, H2 at 0x0C0100, H3 at 0x0C0200.
- **Content.** The code implements 4.3/4.3.1 completely, including E1-E3. The draft in 5.4 shows the structure; the generated `blip_patch.lst` is the reference.

Checks the build performs:

- the original bytes at the three hook addresses are as expected, and every hook decodes as `CALLS` to its entry point;
- the code area is erased (0xFF) and the calibration area is filler (0xC3) before writing;
- every emitted instruction is decoded back with [`c166.py`](DDE41A-RE/tools/c166.py) and compared with the intended instruction and length (235 instructions, 0 errors);
- all changed bytes lie in the hook sites, 0x0C0000-0x0C04E7 and 0x0F7880-0x0F790F (897 program bytes, 52 data bytes).

**State of the images:**

- **Inert.** `wcwFUN_BLP` = 0 and `wrwBLP_MDN` = 0, so the blip stage always outputs 0. Receive object 9 is still configured and polled.
- **Not flashable.** The EPROM checksum isn't corrected (5.6).
- **Placeholders.** `TOUT` (0x0A ticks), `wrwBLP_TMX`, `wrwBLP_TARM`, `wrwBLP_NMX` and `wrwBLP_DME`/`wrwBLP_EPT1` are placeholders until the task period, the CAN log and the final shift maps are known (5.7, 6).
- **Start-up.** RAM isn't cleared at reset, so H2 can poll object 9 once before H1 has configured it if `INIT` still holds 0x5AA5 from before the reset. This is harmless: no new data, at most default data, and H3 is still disabled. The bench test should confirm it.

### 5.6 Checksums and flashing

- **EPROM checksum.** The EDC15C self-test forms a checksum over the external EPROM at terminal 15 on and continuously in the background (§8.4.2/8.4.3). A failure gives restart code 09h, "EPROM checksum not equal to 0". The algorithm is in the segment-0 ROM and isn't a plain 8/16/32-bit sum per 64 KB block or 16 KB sector (all non-zero on the O image). Candidates for the compensation words are the sector trailers, e.g. 0x93FFA-0x93FFF `91 C3 4C 9D 95 14`, and the `AA AA` markers at 0x9FFFE, 0xAFFFE, 0xB7FFE. **Before flashing**, the patched image must be checksum-corrected. Options:
  - use an established EDC15 checksum corrector;
  - determine the algorithm from a dump of the internal ROM (boot-mode routine, see [DDE41A-RE](DDE41A-RE/README.md#segment-0-services-internal-rom)).
- **Calibration.** The new block at 0xF7880-0xF79FF lies in the data area `Y7787646`, which needs the same correction.
- **File checksum.** For WinKFP, the Intel-HEX file needs a correct `$CHECKSUMME` line ([hex2bin.py](DDE41A-RE/tools/hex2bin.py) reads it; a writer must recompute it).
- **Programming route.** Prefer a bench flash with a full backup of the external flash (the `.ori` read in `DDE41A-RE/bin` is the stock reference).

### 5.7 Bench checks before driving

1. **RAM area free:** run the patch with only a canary writer (fill 0xE780-0xE7DF with a pattern, check in the next cycle) and watch for restarts (`edmRSTCD`).
2. **Task period:** count H3 calls in a RAM word against the CANP multiplex counter or a CAN timestamp.
3. **CAN object 9:** send 0x0B5 from a CAN tool and check the buffer, status byte and timeout; EGS1 and the other objects must be unaffected.
4. **Checksum:** after correction the ECU must start without restart code 09h and without new faults.

---

## 6. Test plan

| Step | Setup | Pass criterion |
|---|---|---|
| 0. CANTCU set-up | Race+ RPM Limits, auto-upshift speed and Drive/Sport shift maps for the M67 (Generate, then tune; no red cells) | Shifts behave on the road without the blip; the speed after each downshift is known (input for *wrwBLP_NMX*) |
| 1. Baseline log | Stock bus first (0x0B5 absent?), then stock DDE, CANTCU E38 integration + user output 0x0B5 (10 ms), manual downshifts | 0x0B5 and 0x43F recorded; Target Torque / TCU Intervention / Shift In Progress / Blip % behaviour understood; EGS1 `S_SCHALT`/`GANG_INF`/`MD_IND_GS` timing relative to the request; `MD_NORM` from DDE2 0x329 (`MUL_COD` = 3); `Engine Torque` definition; no DSC/IKE faults with the extra frame present |
| 2. Patch, function off | *wcwFUN_BLP* = 0 | Identical behaviour to stock, no faults, CANP and slave normal |
| 3. Function on, low cap | Small *wrwBLP_MMX*, rolling | Engine speed rises during downshifts only; `wroBLPSTAT` = 1 during the request |
| 4. Fault injection | Disconnect CAN3 / hold TCU Intervention at 1 with a CAN tool | Timeout → ramp to 0 (status 32/2); stuck request → status 4 after *wrwBLP_TMX*, lock after *wrwBLP_LOCK*; no restart; EGS1 fallback unchanged |
| 4a. End-to-end checks | With a CAN tool on CAN3: (a) replay a frozen 0x0B5 during a real downshift; (b) send 0x0B5 = blip without EGS1 `S_SCHALT`; (c) send a large blip request at an engine speed close to *wrwBLP_NMX*; (d) stop 0x0B5 | (a) E1 fails within *wrwBLP_EDEB*, status 64; (b) no blip (E2); (c) blip is cut at *wrwBLP_NMX*, status 128; (d) no blip, timeout status 32; lock after *wrwBLP_EMX* errors |
| 5. Calibrate | Raise *wrwBLP_MMX* in steps, tune CANTCU blip settings | Smooth rev-matched downshifts; no smoke-limit or overboost faults |

---

## 7. Open points

- **User output content:** confirm by log that `Target Torque` is the blip target during `TCU Intervention` = 1 (otherwise use `Blip %`), how `Shift In Progress` frames it, and which variables are available for a user output.
- **Integrity:** the frame has no checksum or alive counter, and CANformance says the user can't add one. The end-to-end substitute checks (4.3.1) cover frozen and wrong frames:
  - E1: torque echo in the request frame;
  - E2: confirmation by the independent EGS1 shift state;
  - E3: fixed engine speed ceiling *wrwBLP_NMX*.

  Still to confirm by log: the exact definition of `Engine Torque` (% of `MD_NORM`, friction or not), the echo delay (for *wrwBLP_DME*, *wrwBLP_EPT1*), and that EGS1 `S_SCHALT`/`GANG_INF` lead the request and `MD_IND_GS` stays 0xFF during a downshift blip (CANformance hasn't answered this). CANformance offered a separate **add-on integration**; a real, protected 0x0B5 would replace E1. An optional second user output could echo the engine speed if a variable exists.
- **Fault and limp behaviour:** what the 0x0B5 frame contains when CANTCU or the transmission is in a fault state (CANformance: not covered by the datastream; ask about the user output). The DDE's timeout and ramp-to-0 handling covers a stopped frame; a frame stuck at "blip" is covered by *wrwBLP_TMX* and E2.
- **Shift maps and *wrwBLP_NMX*:** the ceiling and the blip size depend on the final M67 shift maps and RPM limits (3, "CANTCU configuration for the M67").
- **Extra IDs on CAN3:** the documents show no use of 0x0B5 on the E38 bus (3, "Is 0x0B5 free on the E38 vehicle CAN?"), but nodes the DDE doesn't talk to (Active Cruise Control, if fitted) can't be checked. CANformance asked what "extra IDs" means: it is the one added 8-byte frame. Confirm by log that 0x0B5 is absent from the stock bus and that the DSC and IKE accept the frame without faults.
- **EPROM checksum algorithm** (5.6).
- **Free RAM** proof on the bench (5.7).
- **Third-party EDC15 solution:** CANformance names A.K.T. for EDC15 blips. Comparing with it (message used, limits) would reduce risk.
- **Measurements on the car:** most open points above need the real car and a CAN sniffer. See chapter 8.

---

## 8. Measurements and the CANformance follow-up (parked until the car is back)

**Status (November 2026).** The car is in Poland, where the 8HP is being installed. The current installation has the blips disabled (CANTCU blip requests off, stock DDE firmware). The signals can only be answered by measuring on the car. Once it is back in Slovenia, log CAN3 with a CAN sniffer and then send the follow-up below to CANformance, ideally together with the logs.

**What to log** (CAN3, 500 kbit/s, stock DDE, manual and kickdown downshifts, with the user output 0x0B5 enabled in the CANTCU configuration):

- 0x0B5 (user output) and EGS1 0x43F, with timestamps, so the order of the shift bit, target gear, `MD_IND_GS` and the request can be seen.
- DDE1 0x316 and DDE2 0x329 (`MD_IND_NE`, `MD_REIB`, `MD_NORM` with `MUL_COD` = 3), to define the `Engine Torque` echo and its delay.
- Any DSC/IKE faults with the extra frame on the bus.
- The Race+ RPM Limits and the Drive and Sport shift maps used during the log, so the engine speed after each downshift can be related to *wrwBLP_NMX*.

This answers the open points in chapter 7: the meaning of `Target Torque` and `TCU Intervention`, the timing against EGS1, the `Engine Torque` definition and delay, the `MD_NORM` value (for *wrwBLP_MDN*), the task period, and the speed ceiling.

