#!/bin/bash
# 编译「查词」并安装到 ~/Applications,然后让系统重新登记右键服务
set -e
cd "$(dirname "$0")"
APP="$HOME/Applications/查词.app"

# 1. 编译
swiftc -O main.swift -o chaci

# 2. 组装成 .app 包
pkill -x chaci 2>/dev/null || true
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS"
cp Info.plist "$APP/Contents/Info.plist"
mv chaci "$APP/Contents/MacOS/chaci"

# 3. 本机自签名(不签名系统可能拒绝运行)
codesign --force --sign - "$APP"

# 4. 登记到系统:App 列表 + 右键服务菜单
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f "$APP"
/System/Library/CoreServices/pbs -update

# 5. ⌃⌥D 由 App 自己负责,去掉"服务"上的同名快捷键,避免弹两次
defaults write pbs NSServicesStatus -dict-add '"local.ragepatti.chaci - 查词 - lookup"' \
  '{ enabled_context_menu = 1; enabled_services_menu = 1; presentation_modes = { ContextMenu = 1; ServicesMenu = 1; }; }'
/System/Library/CoreServices/pbs -update

# 6. 现在就在后台启动(要开机自启,另外运行 ./login-item.sh)
open "$APP"

echo "已安装: $APP"
