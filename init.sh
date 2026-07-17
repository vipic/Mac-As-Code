#!/bin/bash
set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

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
    echo
    echo "说明：单个步骤或单个软件失败会记录并继续执行后续步骤；"
    echo "      全部结束后会打印成功 / 失败 / 跳过汇总。"
    exit 1
fi

# 检查 Xcode Command Line Tools
if ! xcode-select -p &>/dev/null; then
    echo "📦 安装 Xcode Command Line Tools..."
    xcode-select --install
    echo "⚠️  安装完成后请重新运行本脚本"
    exit 0
fi

MAC_AS_CODE_RESULTS="$(mktemp -t mac-as-code.XXXXXX)"
export MAC_AS_CODE_RESULTS
: >"$MAC_AS_CODE_RESULTS"
trap 'rm -f "$MAC_AS_CODE_RESULTS"' EXIT

STEP_FAIL_COUNT=0

run_step() {
    local name="$1"
    local description="$2"
    local script="$3"

    if [ -n "$START_FROM" ] && [ "$START_FROM" != "$name" ]; then
        echo "⏭️  跳过：${description}"
        record_result "SKIP" "步骤:$name" "未到达 --from 起始步骤"
        return 0
    fi
    START_FROM=""  # 已到达起始步骤，后续不再跳过

    echo
    echo "$description"
    if bash "$SCRIPT_DIR/$script"; then
        record_result "OK" "步骤:$name" "完成"
    else
        echo "⚠️  步骤失败：${name}（已记录，继续执行后续步骤）"
        record_result "FAIL" "步骤:$name" "脚本退出非零"
        STEP_FAIL_COUNT=$((STEP_FAIL_COUNT + 1))
    fi
}

run_step "defaults" "🔧 修改系统设置..."              "defaults_config.sh"
run_step "git"      "👤 配置 Git 用户信息..."         "git_config.sh"
run_step "brew"     "🍺 安装 Homebrew 及软件..."      "brew.sh"
run_step "zsh"      "🐚 安装 Oh My Zsh..."            "oh_my_zsh.sh"
run_step "dock"     "🖥️  配置 Dock..."                 "defaults_dock.sh"

print_results_summary "$MAC_AS_CODE_RESULTS"
summary_status=$?
persist_results_log "$MAC_AS_CODE_RESULTS" "init"

echo
if [ "$summary_status" -eq 0 ] && [ "$STEP_FAIL_COUNT" -eq 0 ]; then
    echo "✅ 全部完成"
    exit 0
fi

echo "⚠️  执行结束，但仍有失败项；请根据上方汇总手动处理，或重新运行失败相关步骤。"
exit 1
