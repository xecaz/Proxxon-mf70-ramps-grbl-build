# CLAUDE.md

Guidance for Claude Code working in this repo. See `README.md` for the human-facing
overview.

## What this project is

The software/firmware side of a **Proxxon MF 70 CNC** conversion. Goal: replace the
current Estlcam firmware with **GRBL**, then build a Linux toolchain for **soft-material
milling** and **PCB isolation milling**. This is a hardware project — the code here
configures and talks to a **physical machine on `/dev/ttyACM0`**.

## Hardware facts (verified)

- MCU: **ATmega2560** (signature `0x1e9801`), Arduino Mega 2560 (clone; USB `03eb:204b`).
- Driver board: **RAMPS 1.4**, X/Y/Z steppers. **No endstop switches** are installed.
- Spindle: manual speed control, **not** wired to the controller.
- Host: Debian 13. Port access is via ACL on `/dev/ttyACM0` (user also in `dialout`).
- Tooling already present: `arduino-cli`, `avrdude` 7.1, `pyserial` 3.5, `picocom`,
  `minicom`, `screen`, `objcopy`.

## Current state / decisions

- **Firmware flashed & working:** `grbl-Mega-5X` **v1.2i** on the Mega 2560 (RAMPS pin map,
  `N_AXIS` trimmed 5→3). Talks GRBL at 115200 on `/dev/ttyACM0`. Source + built hex under
  `firmware/grbl-Mega-5X/`. Chosen over plain `gnea/grbl` (UNO/328 only) for 2560+RAMPS
  support and G38.2 probing.
- **GRBL configured (no endstops):** `$20=0 $21=0 $22=0` (soft/hard limits + homing off →
  manual work-zeroing), `$100/101/102=6400` steps/mm (**verified with a
  0.01 mm dial indicator**), `$110-112=250` max rate, `$120-122=30` accel, and **`$3=6`** direction mask
  (X normal, Y inverted, Z inverted — confirmed by jogging). Restorable dump:
  `firmware/grbl_settings_mf70.txt`.
- **Software stack:** **bCNC** (sender, installed system-wide via
  `pip3 install --break-system-packages`; a harmless numpy-2 ABI error from the unused
  `opencv-python` camera feature prints at launch — ignore it) + **FreeCAD 1.1.1** (CAM,
  built-in `grbl` post at `.../CAM/Path/Post/scripts/grbl_post.py`, ships a `60degree_Vbit`
  toolbit). First engraving cut ("XecaZ.com", 60° V-bit) completed end-to-end.
- **Backups:** `firmware_backup/` holds the original **Estlcam** flash + EEPROM — the only
  path back to Estlcam. Do not delete.
- **Next:** Z-probe wire + bCNC auto-leveling for PCB; PCB CAM (KiCad → Gerber →
  `pcb2gcode`/FlatCAM).

## Safety rules — READ BEFORE ACTING

1. **Never send motion G-code** (`G0/G1`, `$H`, `$J=…`) without explicit user confirmation
   and knowing the tool position. When discovering axis mapping, jog **small and slow**
   (e.g. 1 mm) and confirm which motor/direction moved before continuing.
2. **avrdude writes are destructive.** Any `-U flash:w` / `-U eeprom:w` or fuse change must
   be confirmed with the user first. Reads (`:r`) and signature checks are safe.
3. **Do not delete or overwrite `firmware_backup/`.** Re-verify it exists before any flash.
4. Before flashing new firmware, re-confirm the backup is intact and restorable.

## Useful commands

```bash
# Safe: identify chip / reach bootloader
avrdude -c wiring -p atmega2560 -P /dev/ttyACM0 -b 115200 -v

# Safe: query GRBL once flashed (115200 baud)
picocom -b 115200 /dev/ttyACM0      # then: $$  $I  ?   (Ctrl-A Ctrl-X to exit)

# Backup / restore (restore is a WRITE — confirm first)
avrdude -c wiring -p atmega2560 -P /dev/ttyACM0 -b 115200 -U flash:r:out.hex:i
avrdude -c wiring -p atmega2560 -P /dev/ttyACM0 -b 115200 -U flash:w:firmware_backup/flash_backup_current.hex:i
```

Serial probes from Python should reset via DTR and read at 115200; note `avrdude`'s reset
handshake differs from a plain DTR pulse, so the bootloader can respond even when a naive
serial probe does not.

## Conventions

- Keep `README.md` and `CLAUDE.md` in sync when hardware facts or the plan change.
- Store scratch/experiments outside the repo; keep committed files limited to docs,
  firmware configs/builds, and backups.
- Record any newly discovered wiring/config (driver type, microstepping, steps/mm,
  direction flips) in `README.md` as it's learned — the user rebuilt this years ago and
  the wiring is being reverse-engineered.
