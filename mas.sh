#!/bin/bash
set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BREWFILE="$SCRIPT_DIR/Brewfile"

#############################
## 安装 App Store 应用（mas）##
#############################

if ! command -v mas &>/dev/null; then
    echo "❌ mas 未安装，请先运行 brew.sh"
    exit 1
fi

echo "📱 请确保已登录 App Store"
mas signin --dialog 2>/dev/null || true

if ! command -v brew &>/dev/null; then
    echo "❌ brew 未安装，请先运行 brew.sh"
    exit 1
fi

echo "📦 安装 Brewfile 中启用的 App Store 应用..."

# Brewfile 是唯一准源。这里通过跳过 formula/cask，只安装启用的 mas 条目。
export HOMEBREW_BUNDLE_BREW_SKIP
export HOMEBREW_BUNDLE_CASK_SKIP
HOMEBREW_BUNDLE_BREW_SKIP="$(brew bundle list --formula --file="$BREWFILE" | tr '\n' ' ')"
HOMEBREW_BUNDLE_CASK_SKIP="$(brew bundle list --cask --file="$BREWFILE" | tr '\n' ' ')"

brew bundle --file="$BREWFILE"

echo "✅ App Store 应用安装完成"
