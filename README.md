# 查词 · word-lookup

A tiny macOS app that looks up any English word, from almost any app, in one keystroke:
**Chinese meaning + UK/US phonetics + UK/US pronunciation audio.**

Select a word → press **⌃⌥D** (Control + Option + D) → a small floating window appears next to the mouse.

Works in Google Docs, Word, Pages, Notes, Chrome/Safari web pages, PDFs — anywhere you can select and copy text.

```
┌ unrelenting ───────────────────────────────┐
│ unrelenting | BrE ʌnrɪˈlɛntɪŋ, AmE …       │
│ adjective                                  │
│ ① (not diminishing) 持续的 chíxù de …      │
│     ▸ …                                    │
│ ② (unyielding) 不屈服的 bù qūfú de         │
│                                            │
│ [🔊 英] [🔊 美]          [在高山词根中打开] │
└────────────────────────────────────────────┘
```

## Features

- **⌃⌥D global shortcut** — copies your selection, looks it up, then puts your old clipboard back.
- **Right-click → Services → 查词** — in normal Mac apps (not Google Docs, see below).
- **Offline meanings** from the *Simplified Chinese – English* (Oxford) dictionary that ships with macOS. Handles word forms: "running" → *run*.
- **🔊 英 / 🔊 美** buttons (or keys `1` / `2`) play real UK and US recordings.
- **在高山词根中打开** opens the word in the 高山词根 app, if you have it, for word-root explanations.
- **Esc** closes the window. No Dock icon; runs quietly in the background.

## Requirements

- macOS 13 or newer (built and tested on macOS 27, Apple Silicon)
- Xcode Command Line Tools for the Swift compiler — install with `xcode-select --install` if `swiftc` is missing
- The *Simplified Chinese – English* dictionary enabled in the **Dictionary** app (Settings → tick it). It's usually already there.

## Install

```bash
git clone https://github.com/ptao73/word-lookup.git
cd word-lookup
./build.sh
```

`build.sh` compiles `main.swift`, packs it into `~/Applications/查词.app`, signs it locally, registers the right-click item, and starts it.

### Allow it to copy your selection (one time)

⌃⌥D presses ⌘C for you, which macOS only allows after you grant **Accessibility** permission:

1. **System Settings → Privacy & Security → Accessibility**
2. Click **+**, press **⌘⇧G**, type `~/Applications/查词.app`, click **Open**
3. Make sure the switch is **on**

Without this permission ⌃⌥D still works in two steps: select → **⌘C** → **⌃⌥D** (it looks up whatever you last copied).

### Start automatically at login (optional)

```bash
./login-item.sh
```

This adds a LaunchAgent so 查词 is always running and ⌃⌥D is always available. Without it, start the app by hand after a restart: `open ~/Applications/查词.app`.

## How it works

| Part | Where it comes from |
|---|---|
| Meanings & phonetics | macOS built-in Oxford Chinese–English dictionary, read through `DCSCopyTextDefinition` (plus the private `DCSDictionaryCreate` to pick that specific dictionary) |
| Pronunciation | Youdao's public audio URL: `https://dict.youdao.com/dictvoice?audio=<word>&type=1` (UK) / `type=2` (US) |
| ⌃⌥D | Carbon `RegisterEventHotKey`; simulated ⌘C via `CGEvent`; clipboard saved & restored |
| Right-click | macOS Services (`NSServices` in `Info.plist`) |
| 高山词根 button | opens the `ghosundict://<word>` link that the 高山词根 app registers |

### Why ⌃⌥D copies instead of reading the selection directly

Google Docs draws its text itself, so macOS can't see what you selected — the right-click Services item receives nothing there. Copying (⌘C) works in Docs, so the shortcut goes through the clipboard instead.

## Files

| File | What it is |
|---|---|
| `main.swift` | The whole app (~200 lines, with Chinese comments) |
| `Info.plist` | App identity, right-click service, `chaci://` link |
| `build.sh` | Compile, install to `~/Applications`, register, start |
| `login-item.sh` | Optional: start at login |

Other ways to open a lookup: `open "chaci://carbon"` or `open -a 查词 --args carbon`.

## Known limitations

- **Rebuilding resets Accessibility.** The app is self-signed, so macOS treats every new build as a new app — grant permission again after `./build.sh`.
- **Youdao audio is unofficial.** It's a public URL, not a documented API, and could change.
- **Private macOS function.** `DCSDictionaryCreate` isn't public API; a future macOS could break the meaning lookup.
- **The 高山词根 button** depends on that app's link format; it may open the app without jumping to the word.
- English → Chinese only.

## Uninstall

```bash
launchctl bootout gui/$(id -u)/local.ragepatti.chaci 2>/dev/null
rm -f ~/Library/LaunchAgents/local.ragepatti.chaci.plist
pkill -x chaci; rm -rf ~/Applications/查词.app
/System/Library/CoreServices/pbs -update
```

Then remove 查词 from **System Settings → Privacy & Security → Accessibility**.

## Notes

Personal tool. Not affiliated with 高山词根 / Ghosun, Youdao, Oxford, or Apple. No dictionary content is included in this repository — meanings are read from your own Mac's dictionary at runtime.
