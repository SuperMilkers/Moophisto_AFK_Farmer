# Moophisto AFK Farmer

Moophisto AFK Farmer is a simple AutoHotkey v1 script for Diablo IV designed to help farm the **Moophisto boss** at the Bovine Sanctum for **cow-related items and other gear**.

It automatically casts all six skill slots in a randomized order, can randomly double or triple cast skills, supports channeled abilities, and periodically moves the character within a small area.

## Features

- Randomized six-skill casting
- Default skill keys: `1`, `2`, `3`, `4`, `5`, `RButton`
- Random single, double, and triple casts
- Per-skill key reassignment
- Optional channeled skills
- Configurable channel hold time
- Random movement using left-click
- Configurable cast and movement timing
- On-screen status overlay
- Skill cycle, cast, movement, and runtime counters
- Pause/resume hotkey

## Requirements

- Windows
- [AutoHotkey v1.1](https://www.autohotkey.com/)

## Quick Installation

1. Download and install [AutoHotkey v1.1](https://www.autohotkey.com/).
2. Download the `Moophisto-AFK-Farmer.ahk` script.
3. In Diablo IV, teleport to **Bovine Sanctum**.
4. Position yourself near the boss, but not close enough to be killed.
5. Double-click the `.ahk` file to start the script.
6. Use the hotkeys below to configure or control it.

AutoHotkey v1 documentation:  
https://www.autohotkey.com/docs/v1/

## Controls

- `F8` - Pause / Resume
- `F10` - Open Settings
- `F12` - Exit

## Default Settings

- Skills: `1`, `2`, `3`, `4`, `5`, `RButton`
- Skill cycle: 15–45 seconds
- Movement: 20–40 seconds
- Double cast chance: 20%
- Triple cast chance: 10%
- Channeling: Off by default
- Movement input: `LButton`

## Settings

Press `F10` to configure:

- Skill keys
- Channeled skills
- Channel hold time
- Skill cycle timing
- Delay between skills
- Double/triple cast chances
- Movement timing
- Movement radius

## Overlay

Displays:

```text
Moophisto AFK Farmer
RUNNING

Skill Cycles: 0
Skill Casts: 0
Moves: 0
Runtime: 00:00:00
Next Skill Cycle: 24 sec
Next Move: 15 sec
Skills: 1 | 2 | 3 | 4 | 5 | RButton