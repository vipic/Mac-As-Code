#!/bin/sh
set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib/common.sh
. "$SCRIPT_DIR/lib/common.sh"

if ! command -v create_default_plan >/dev/null 2>&1; then
    echo "❌ 未能加载 lib/common.sh（${SCRIPT_DIR}/lib/common.sh）"
    echo "   请在仓库根目录执行：sh init.sh  或  bash init.sh"
    exit 1
fi

START_FROM=""
SKIP_DOCTOR=0
YES_MODE=0
PLAN_FILE=""

usage() {
    cat <<'EOF'
用法：sh init.sh [--from <步骤名>] [--skip-doctor] [--yes]
      bash init.sh 亦可

装机主入口：分步多选（↑↓ / 空格）→ 系统设置 → 软件 → Dock。
若包含 App Store 应用，会在最开始打开 App Store 并等待登录确认。

步骤名：defaults, brew, zsh, dock
示例：
  sh init.sh
  bash init.sh
  sh init.sh --from brew
  sh init.sh --yes              # 跳过多选，默认全选
  sh init.sh --skip-doctor

Git 用户信息随 backup / restore 迁移 ~/.gitconfig，不在装机流程里配置。
EOF
}

while [ "$#" -gt 0 ]; do
    case "$1" in
        -h|--help)
            usage
            exit 0
            ;;
        --skip-doctor)
            SKIP_DOCTOR=1
            shift
            ;;
        --yes|-y)
            YES_MODE=1
            shift
            ;;
        --from)
            if [ -z "${2:-}" ]; then
                echo "❌ --from 需要指定步骤名：defaults, brew, zsh, dock"
                exit 1
            fi
            START_FROM="$2"
            shift 2
            ;;
        *)
            echo "❌ 未知参数：$1"
            usage
            exit 1
            ;;
    esac
done

# 检查 Xcode Command Line Tools
if ! xcode-select -p >/dev/null 2>&1; then
    echo "📦 安装 Xcode Command Line Tools..."
    xcode-select --install
    echo "⚠️  安装完成后请重新运行本脚本"
    exit 0
fi

if [ "$SKIP_DOCTOR" -eq 0 ]; then
    echo
    echo "======== 装机前检查 ========"
    if ! sh "$SCRIPT_DIR/doctor.sh" --pre; then
        echo "⚠️  装机前检查未通过；若仍要继续，可用：sh init.sh --skip-doctor"
        exit 1
    fi
fi

PLAN_FILE="$(mktemp -t mac-as-code-plan.XXXXXX)"
export MAC_AS_CODE_PLAN="$PLAN_FILE"
MAC_AS_CODE_RESULTS="$(mktemp -t mac-as-code.XXXXXX)"
export MAC_AS_CODE_RESULTS
: >"$MAC_AS_CODE_RESULTS"
trap 'rm -f "$MAC_AS_CODE_RESULTS" "$PLAN_FILE"' EXIT

create_default_plan "$SCRIPT_DIR/Brewfile" "$PLAN_FILE" "$SCRIPT_DIR"
edit_plan_interactive "$PLAN_FILE" "$YES_MODE"
plan_status=$?
if [ "$plan_status" -eq 2 ]; then
    exit 0
fi
if [ "$plan_status" -ne 0 ]; then
    exit "$plan_status"
fi

set_plan_all_type_mas_off() {
    tmp="$(mktemp -t mac-as-code-plan.XXXXXX)"
    awk -F'|' 'BEGIN{OFS="|"} $2=="mas"{$1="OFF"} {print}' "$PLAN_FILE" >"$tmp"
    /usr/bin/ditto "$tmp" "$PLAN_FILE"
    rm -f "$tmp"
}

# App Store：若计划里有 mas，在装机开始前登录并确认清单，之后不再打断
confirm_mas_upfront() {
    mas_on=0

    while IFS='|' read -r state type name id; do
        [ "$state" = "ON" ] && [ "$type" = "mas" ] || continue
        mas_on=$((mas_on + 1))
    done <"$PLAN_FILE"

    if [ "$mas_on" -eq 0 ]; then
        export MAC_AS_CODE_SKIP_MAS=1
        return 0
    fi

    echo
    echo "======== App Store 登录（共 ${mas_on} 个应用）========"
    echo "将安装以下 App Store 应用（请确认账号能获取它们）："
    while IFS='|' read -r state type name id; do
        [ "$state" = "ON" ] && [ "$type" = "mas" ] || continue
        echo "  - ${name}（id: ${id}）"
    done <"$PLAN_FILE"
    echo

    if [ "$YES_MODE" = "1" ] || [ ! -t 0 ]; then
        echo "ℹ️  非交互模式：假定已登录 App Store，稍后直接安装"
        export MAC_AS_CODE_MAS_READY=1
        return 0
    fi

    echo "请先在 App Store 登录对应的 Apple 账号（脚本会打开 App Store）。"
    echo "登录并确认无误后回到此终端："
    echo "  - 直接按 Enter：继续（之后不再询问 App Store）"
    echo "  - 输入 s 后按 Enter：跳过全部 App Store 应用"
    open -a "App Store" 2>/dev/null || true

    while true; do
        printf "App Store 已登录？[Enter=继续 / s=全部跳过] > "
        if ! read -r answer; then
            answer="s"
        fi
        case "$answer" in
            s|S)
                echo "⏭️  已跳过全部 App Store 应用"
                export MAC_AS_CODE_SKIP_MAS=1
                set_plan_all_type_mas_off
                return 0
                ;;
            *)
                export MAC_AS_CODE_MAS_READY=1
                echo "✅ 已确认 App Store 登录，开始装机"
                return 0
                ;;
        esac
    done
}

confirm_mas_upfront

STEP_FAIL_COUNT=0

run_step() {
    name="$1"
    description="$2"
    script="$3"

    if [ -n "$START_FROM" ] && [ "$START_FROM" != "$name" ]; then
        echo "⏭️  跳过：${description}"
        record_result "SKIP" "步骤:$name" "未到达 --from 起始步骤"
        return 0
    fi
    START_FROM=""

    echo
    echo "$description"
    if sh "$SCRIPT_DIR/$script"; then
        record_result "OK" "步骤:$name" "完成"
    else
        echo "⚠️  步骤失败：${name}（已记录，继续执行后续步骤）"
        record_result "FAIL" "步骤:$name" "脚本退出非零"
        STEP_FAIL_COUNT=$((STEP_FAIL_COUNT + 1))
    fi
}

maybe_run_type() {
    type_name="$1"
    step_name="$2"
    description="$3"
    script="$4"

    if ! plan_has_on "$PLAN_FILE" "$type_name"; then
        echo
        echo "⏭️  跳过：${description}（未选中任何项）"
        record_result "SKIP" "步骤:$step_name" "用户未选中"
        return 0
    fi
    run_step "$step_name" "$description" "$script"
}

maybe_run_brew() {
    brew_on="$(plan_count_on "$PLAN_FILE" "brew")"
    cask_on="$(plan_count_on "$PLAN_FILE" "cask")"
    mas_on="$(plan_count_on "$PLAN_FILE" "mas")"

    if [ "${brew_on:-0}" -eq 0 ] && [ "${cask_on:-0}" -eq 0 ] && [ "${mas_on:-0}" -eq 0 ]; then
        echo
        echo "⏭️  跳过：安装 Homebrew 及软件（未选中任何软件）"
        record_result "SKIP" "步骤:brew" "用户未选中任何软件"
        return 0
    fi

    run_step "brew" "🍺 安装 Homebrew 及软件..." "brew.sh"
}

maybe_run_type "defaults" "defaults" "🔧 修改系统设置..." "defaults_config.sh"
maybe_run_brew

if plan_has_on "$PLAN_FILE" "plugin" "oh-my-zsh"; then
    run_step "zsh" "🐚 安装 Oh My Zsh..." "oh_my_zsh.sh"
else
    echo
    echo "⏭️  跳过：🐚 安装 Oh My Zsh...（未选中）"
    record_result "SKIP" "步骤:zsh" "用户未选中"
fi

maybe_run_type "dock" "dock" "🖥️  配置 Dock..." "defaults_dock.sh"

print_results_summary "$MAC_AS_CODE_RESULTS"
summary_status=$?
persist_results_log "$MAC_AS_CODE_RESULTS" "init"

if [ "$SKIP_DOCTOR" -eq 0 ]; then
    echo
    echo "======== 装机后检查 ========"
    if ! sh "$SCRIPT_DIR/doctor.sh" --post; then
        STEP_FAIL_COUNT=$((STEP_FAIL_COUNT + 1))
    fi
fi

echo
if [ "$summary_status" -eq 0 ] && [ "$STEP_FAIL_COUNT" -eq 0 ]; then
    echo "✅ 全部完成"
    echo "如需恢复个人数据（含 Git 配置）：进入 backup 快照目录执行 sh restore.sh"
    exit 0
fi

echo "⚠️  执行结束，但仍有失败项；请根据上方汇总手动处理，或重新运行失败相关步骤。"
exit 1
