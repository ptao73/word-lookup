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

echo "已安装: $APP"
