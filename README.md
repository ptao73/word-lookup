# 查词 (word-lookup)

Look up any English word from (almost) any Mac app: Chinese meaning + UK/US pronunciation.

## How to use
- **Right-click:** select a word → right-click → **Services → 查词** (in some apps it's directly in the menu).
- **Shortcut ⌃⌥D** (Control + Option + D) — works everywhere, **including Google Docs**:
  - With Accessibility permission (System Settings → Privacy & Security → Accessibility → add `~/Applications/查词.app`): select a word → ⌃⌥D. The app copies the selection for you and restores your clipboard.
  - Without it: select → ⌘C → ⌃⌥D (looks up what you last copied).
  - The app must be running: `open ~/Applications/查词.app`, or run `./login-item.sh` once to start it at every login.
  - After `./build.sh` the Accessibility permission must be granted again (the self-signed app counts as new).
- **Link:** `open "chaci://carbon"`.
- In the window: **🔊 英** / **🔊 美** (or keys `1` / `2`), **在高山词根中打开**, **Esc** to close.

## Where things come from
- Meanings: macOS built-in *Simplified Chinese – English* (Oxford) dictionary, offline.
- Sounds: Youdao public pronunciation URL (`dict.youdao.com/dictvoice`, unofficial — may change).
- 高山词根 button: opens `ghosundict://<word>`.

## Files
- `main.swift` — the whole app
- `Info.plist` — registers the right-click service and `chaci://` link
- `build.sh` — compile + install to `~/Applications/查词.app` and start it
- `login-item.sh` — optional: start 查词 at login

## Rebuild / remove
```bash
./build.sh
```
```bash
launchctl bootout gui/$(id -u)/local.ragepatti.chaci 2>/dev/null; rm -f ~/Library/LaunchAgents/local.ragepatti.chaci.plist; pkill -x chaci; rm -rf ~/Applications/查词.app; /System/Library/CoreServices/pbs -update
```
