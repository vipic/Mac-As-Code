#!/bin/bash
set -eu

#############################
## 安装 App Store 应用（mas）##
#############################

if ! command -v mas &>/dev/null; then
    echo "❌ mas 未安装，请先运行 brew.sh"
    exit 1
fi

echo "📱 请确保已登录 App Store"
mas signin --dialog 2>/dev/null || true

echo "📦 安装 App Store 应用..."

mas install 1451544217  # Adobe Lightroom
mas install 425264550   # Blackmagic Disk Speed Test
mas install 571213070   # DaVinci Resolve
mas install 1435957248  # Drafts
mas install 1136220934  # Infuse
mas install 409183694   # Keynote
mas install 409203825   # Numbers
mas install 409201541   # Pages
mas install 425424353   # The Unarchiver
mas install 836500024   # WeChat

echo "✅ App Store 应用安装完成"
