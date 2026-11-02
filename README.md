# BMW E38 740d (M67) DDE: reverse engineering and downshift blip

Analysis of the BMW M67 V8 diesel engine control units (Bosch DDE4.1 / EDC15C in the E38 740d, DDE5.1 and DDE6.3 / EDC16 in the E65), aimed at adding an E65-style **downshift blip** to the E38 after converting it to a ZF 8HP transmission controlled by **CANTCU** (CANformance Race+).

## Main documents

| Document | Content |
|---|---|
| [Blip-Function.md](Blip-Function.md) | Downshift blip for the DDE4.1: DDE6.3 reference, the E65 TORQUE_GEARBX frame on 0x0B5 (CANTCU add-on integration, interim User CAN Output), M67 CANTCU configuration, function description, firmware patch design, build and self-test, in two options: Option 1 with switchable extra protections and Option 2, strict E65 (chapter 9) |
| [CANTCU-Installation.md](../E38-8HP-Conversion/CANTCU-Installation.md) | CANTCU / 8HP installation in the E38, including the DDE4.1 CAN topology |
| [M67-DDE41-Findings.md](M67-DDE41-Findings.md) | E38 740d DDE4.1 (EDC15C): releases, SGBDs, master/slave CAN, reverse engineering summary |
| [M67-DDE51-Findings.md](M67-DDE51-Findings.md) | E65 740d DDE5.1 (EDC16C1) and the GS19 transmission |
| [M67-DDE63-Findings.md](M67-DDE63-Findings.md) | E65 745d DDE6.3 (EDC16CP35): gearbox torque interface and downshift blip |

## Folders

| Folder | Content |
|---|---|
| [DDE41A-RE/](DDE41A-RE/README.md) | DDE4.1 master: C167 disassembly, measurement and calibration tables, CANP protocol, blip patch builder (`tools/blip_patch.py`) |
| [DDE41B-RE/](DDE41B-RE/README.md) | DDE4.1 slave |
| [DDE51-RE/](DDE51-RE/README.md) | DDE5.1 PowerPC analysis, GS19 transmission data |
| [DDE63-RE/](DDE63-RE/README.md) | DDE6.3 PowerPC analysis, [EGS torque intervention function description](DDE63-RE/Function-Description-EGS-Torque-Intervention.md), GS19.11 data |

The BMW SP-Daten, BMW Standard Tools, the Bosch EDC15C function description (a Markdown conversion and English translation of Bosch Y 445 S00 003-CC0) and all firmware images (`*.bin`, `*.ori`) aren't included. The tools expect them in a `Shared` folder **next to** this repository, which can be used by other projects too:

```text
<parent>\
  E38-M67\                                       this repository
  Shared\SP-Daten\E38, E65                       BMW SP-Daten v60.1 (ecu, data, daten, ...)
  Shared\BMW-StandardTools\                      EDIABAS ECU / EnglishEcu, EC-APPS\INPA\SGDAT (optional: English SGBD texts, INPA screens)
  Shared\Documentation\EDC15C-Function-Description\   (optional: map name hints; the document links only work with it)
  Shared\EdiabasLib\                             (optional: EdiabasTest.exe for the simulator probe, see DDE41A-RE)
```

Run the tools in `*/tools` to regenerate the images and outputs.

## Licensing

- **Code** (`*/tools/*.py`): [MIT](LICENSE)
- **Original documentation**: [CC BY-NC-SA 4.0](LICENSE-docs)
- **Third-party material** (BMW SGBD data, firmware-derived listings, the GPL-3.0 opcode table): not licensed by this repository, see [NOTICE.md](NOTICE.md)

**Disclaimer:** this repository describes modifications to engine control firmware. Everything is provided as is, without warranty. Using it can damage the vehicle, affect emissions and road legality, and is at your own risk. See [NOTICE.md](NOTICE.md#disclaimer).
