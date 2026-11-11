# 查词 (word-lookup)

Look up any English word from (almost) any Mac app: Chinese meaning + UK/US pronunciation.

## How to use
- **Right-click:** select a word → right-click → **Services → 查词** (in some apps it's directly in the menu).
- **Shortcut:** select a word → **⌃⌥D** (Control + Option + D).
- **Link:** `open "chaci://carbon"`.
- In the window: **🔊 英** / **🔊 美** (or keys `1` / `2`), **在高山词根中打开**, **Esc** to close.

## Where things come from
- Meanings: macOS built-in *Simplified Chinese – English* (Oxford) dictionary, offline.
- Sounds: Youdao public pronunciation URL (`dict.youdao.com/dictvoice`, unofficial — may change).
- 高山词根 button: opens `ghosundict://<word>`.

## Files
- `main.swift` — the whole app
- `Info.plist` — registers the right-click service and `chaci://` link
- `build.sh` — compile + install to `~/Applications/查词.app`

## Rebuild / remove
```bash
./build.sh
```
```bash
pkill -x chaci; rm -rf ~/Applications/查词.app; /System/Library/CoreServices/pbs -update
```
