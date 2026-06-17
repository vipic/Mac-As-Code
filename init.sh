#!/bin/bash
set -eu

# 检查 Xcode Command Line Tools
if ! xcode-select -p &>/dev/null; then
    echo "📦 安装 Xcode Command Line Tools..."
    xcode-select --install
    echo "⚠️  安装完成后请重新运行本脚本"
    exit 0
fi

echo "🔧 修改系统设置..."
source "$(dirname "$0")/defaults_config.sh"

echo "🍺 安装 Homebrew 及软件..."
source "$(dirname "$0")/brew.sh"

echo "🐚 安装 Oh My Zsh..."
bash "$(dirname "$0")/oh_my_zsh.sh"

echo "🖥️  配置 Dock..."
source "$(dirname "$0")/defaults_dock.sh"

echo "✅ 全部完成"
