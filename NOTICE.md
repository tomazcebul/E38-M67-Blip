# Notices

## Licences in this repository

| Content | Licence |
|---|---|
| Source code written for this project (`*/tools/*.py`) | MIT, see [LICENSE](LICENSE) |
| Original documentation (findings, design and installation documents, READMEs) | CC BY-NC-SA 4.0, see [LICENSE-docs](LICENSE-docs) |
| Third-party material listed below | **Not licensed by this repository.** All rights remain with their owners |

## Third-party material

The following content is included for research, documentation and interoperability purposes only. No rights are claimed and no licence is granted for it.

| Content | Location | Owner |
|---|---|---|
| Bosch EDC15C software function description (Y 445 S00 003-CC0), Markdown conversion and English translation, figures | [`EDC15C-Function-Description/`](EDC15C-Function-Description) | Robert Bosch GmbH |
| Tables decoded from BMW diagnostic description files (SGBD `.prg`) | `*/sgbd/` | BMW AG |
| Disassembly listings, cross references, calibration tables, map/curve extracts and other outputs derived from BMW/Bosch control-unit firmware | `*/out/`, `DDE41A-RE/patch/blip_patch.lst` | BMW AG / Robert Bosch GmbH (underlying firmware) |
| Transmission data extracts derived from ZF/BMW firmware | `DDE51-RE/egs/`, `DDE63-RE/egs/` | ZF Friedrichshafen AG / BMW AG |
| C166 opcode reference table | [`DDE41A-RE/tools/c166_is_ref.txt`](DDE41A-RE/tools/c166_is_ref.txt) | [hn/c166-dis](https://github.com/hn/c166-dis), **GPL-3.0** |

The BMW SP-Daten files and all firmware images (`*.bin`, `*.ori`) are **not** part of this repository (see [.gitignore](.gitignore)). The tools regenerate the images from a local SP-Daten copy.

Product and company names (BMW, Bosch, ZF, CANformance, CANTCU, ...) are trademarks of their respective owners. This project isn't affiliated with or endorsed by any of them.

## Disclaimer

This repository describes reverse engineering of engine and transmission control units and a **modification of engine control firmware** (downshift blip for the BMW M67 DDE4.1).

- Everything is provided **as is, without warranty of any kind**. The patch in [Blip-Function.md](Blip-Function.md) is an **untested design draft**.
- Modifying engine control software can damage the engine, drivetrain or control units. It can cause unexpected vehicle behaviour and lead to accidents.
- Modified engine software can affect emissions, type approval, road legality and insurance cover. Check the regulations that apply to you before using it on a public road.
- You use any information, tool or file from this repository **at your own risk**. The authors accept no liability for damage, injury or legal consequences.
