#!/bin/bash
# 让「查词」在登录时自动在后台启动(⌃⌥D 快捷键需要它一直开着)
# 取消: launchctl bootout gui/$(id -u)/local.ragepatti.chaci && rm ~/Library/LaunchAgents/local.ragepatti.chaci.plist
set -e
APP="$HOME/Applications/查词.app"
# 6. 开机/登录时自动在后台启动(快捷键要 App 一直开着才能用)
AGENT="$HOME/Library/LaunchAgents/local.ragepatti.chaci.plist"
cat > "$AGENT" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>Label</key><string>local.ragepatti.chaci</string>
  <key>ProgramArguments</key><array><string>$APP/Contents/MacOS/chaci</string></array>
  <key>RunAtLoad</key><true/>
</dict></plist>
PLIST
launchctl bootout gui/$(id -u)/local.ragepatti.chaci 2>/dev/null || true
launchctl bootstrap gui/$(id -u) "$AGENT"

echo "已设置登录自启"
