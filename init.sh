#!/bin/bash
set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# 解析 --from 参数，支持断点续跑
START_FROM=""
if [ "${1:-}" = "--from" ]; then
    if [ -z "${2:-}" ]; then
        echo "❌ --from 需要指定步骤名：defaults, git, brew, zsh, dock"
        exit 1
    fi
    START_FROM="$2"
elif [ "${1:-}" != "" ]; then
    echo "用法：bash init.sh [--from <步骤名>]"
    echo "步骤名：defaults, git, brew, zsh, dock"
    echo "示例：bash init.sh --from brew   # 从 brew 开始（跳过 defaults 和 git）"
    exit 1
fi

# 检查 Xcode Command Line Tools
if ! xcode-select -p &>/dev/null; then
    echo "📦 安装 Xcode Command Line Tools..."
    xcode-select --install
    echo "⚠️  安装完成后请重新运行本脚本"
    exit 0
fi

run_step() {
    local name="$1"
    local description="$2"
    local script="$3"

    if [ -n "$START_FROM" ] && [ "$START_FROM" != "$name" ]; then
        echo "⏭️  跳过：${description}"
        return 0
    fi
    START_FROM=""  # 已到达起始步骤，后续不再跳过

    echo
    echo "$description"
    bash "$SCRIPT_DIR/$script"
}

run_step "defaults" "🔧 修改系统设置..."              "defaults_config.sh"
run_step "git"      "👤 配置 Git 用户信息..."         "git_config.sh"
run_step "brew"     "🍺 安装 Homebrew 及软件..."      "brew.sh"
run_step "zsh"      "🐚 安装 Oh My Zsh..."            "oh_my_zsh.sh"
run_step "dock"     "🖥️  配置 Dock..."                 "defaults_dock.sh"

echo
echo "✅ 全部完成"
