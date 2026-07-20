# Milling Machine — Proxxon MF 70 CNC

A DIY CNC conversion of a **Proxxon MF 70** benchtop mill, driven by a **RAMPS 1.4**
board on an **Arduino Mega 2560**. This repo tracks the software/firmware side of the
build: getting modern **GRBL** onto the controller and standing up a Linux toolchain for
**light milling (soft materials)** and **PCB isolation milling**.

## Hardware

| Part | Detail |
|------|--------|
| Machine | Proxxon MF 70 (manual mill converted to CNC) |
| Controller | Arduino **Mega 2560** (ATmega2560, sig `0x1e9801`) |
| Driver board | **RAMPS 1.4** with **DRV8825** drivers, **1/32 microstepping** (all 3 jumpers fitted) |
| Axes | X→X, Y→Y, Z→Z sockets; steppers only, **no endstop switches installed** |
| Power | **12 V / 20 A** PSU into the RAMPS power header |
| Spindle | Proxxon spindle on its own manual speed control (not controller-driven) |
| Host | Debian 13 (trixie), board on `/dev/ttyACM0` |

USB enumerates as `03eb:204b` (Atmel LUFA serial) — the 16u2 USB-serial chip of a
clone Mega 2560.

## Current status

- **Firmware on the board today:** Estlcam V11.004 controller firmware (Marlin-based) —
  **not GRBL**. This is why GRBL serial probes get no response; Estlcam speaks its own
  protocol driven by the Windows Estlcam app.
- **Backups taken** (see `firmware_backup/`): full flash + EEPROM images, so the Estlcam
  setup is fully restorable.
- **Decision:** replace Estlcam with **grbl-Mega-5X** (fra589) — GRBL 1.1 for the
  ATmega2560 with native RAMPS 1.4 support (limits, homing, and G38.2 **probing**, which
  PCB auto-leveling needs). Plain `gnea/grbl` targets the UNO/328 and is the wrong build;
  grblHAL/FluidNC are better but need 32-bit hardware we don't have.
- **Firmware built:** `grbl-Mega-5X` **v1.2i** compiled for the Mega 2560 (RAMPS pin map,
  trimmed to 3 axes) → `firmware/grbl-Mega-5X/build_out/grblUpload.ino.hex`. Not yet
  flashed.
- **Not yet done:** flash GRBL, configure `$$` settings (steps/mm, homing off), wire a
  Z-probe for PCB leveling, install a sender + CAM toolchain.

Because there are **no endstops**, GRBL will run with homing/hard-limits disabled
(`$22=0`, `$21=0`) and manual work-zeroing at the workpiece corner — standard for hobby
PCB / light milling.

## Roadmap

1. **Firmware** — build grbl-Mega-5X with the RAMPS 1.4 pin map, flash via the bootloader.
2. **Sender (Linux)** — bCNC or cncjs (both have probe/auto-level widgets) for streaming
   G-code, jogging, and copper height-mapping. UGS as a general-purpose alternative.
3. **PCB CAD → CAM** — KiCad → Gerbers → isolation/drill/cutout G-code via `pcb2gcode`
   (apt-installable) or FlatCAM.
4. **Calibration & first cuts** — set steps/mm, discover axis/direction by jogging,
   air cuts, surface + auto-level a copper-clad board, mill a test pattern.

## Repository layout

```
.
├── README.md                 # this file
├── CLAUDE.md                 # guidance for Claude Code sessions
└── firmware_backup/          # pre-flash safety net (do not delete)
    ├── flash_backup_current.hex    # Estlcam application flash (Intel HEX)
    ├── eeprom_backup_current.hex   # Estlcam EEPROM / machine params
    ├── flash.bin / eeprom.bin      # binary conversions (for inspection)
```

### Captured Estlcam EEPROM parameters (for cross-reference)

Decoded little-endian floats from the original EEPROM (undocumented Estlcam layout):
`6400, 400, 200, 51200, 57600, -42`. Confirmed: `200` = motor full-steps/rev and
`6400 = 200 × 32` matches the **1/32 microstepping** (all 3 DRV8825 jumpers fitted). With
the MF70's ~1 mm leadscrew this implies **≈6400 steps/mm** — the starting value for GRBL
`$100/$101/$102`, to be verified by measurement during calibration.

## Talking to the board

```bash
# Identify MCU / reach the bootloader (safe, read-only):
avrdude -c wiring -p atmega2560 -P /dev/ttyACM0 -b 115200 -v

# Re-read backups if ever needed:
avrdude -c wiring -p atmega2560 -P /dev/ttyACM0 -b 115200 -U flash:r:flash.hex:i
avrdude -c wiring -p atmega2560 -P /dev/ttyACM0 -b 115200 -U eeprom:r:eeprom.hex:i

# Restore the original Estlcam firmware if desired:
avrdude -c wiring -p atmega2560 -P /dev/ttyACM0 -b 115200 \
        -U flash:w:firmware_backup/flash_backup_current.hex:i
```

Once GRBL is flashed it speaks at **115200 baud**; connect with `picocom -b 115200
/dev/ttyACM0` and type `$$` for settings, `$I` for build info, `?` for live status.

## Safety notes

- The board and machine are **real hardware**. Never stream motion G-code without knowing
  where the tool is; jog small and slow when discovering axis mapping.
- Keep `firmware_backup/` intact — it is the only route back to the original Estlcam setup.
