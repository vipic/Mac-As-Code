#!/bin/sh
set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib/common.sh
. "$SCRIPT_DIR/lib/common.sh"

BREWFILE="$SCRIPT_DIR/Brewfile"
FAIL_COUNT=0
SKIP_ALL_MAS=0

init_results

#############################
## 安装 App Store 应用（mas）##
#############################

if [ "${MAC_AS_CODE_SKIP_MAS:-}" = "1" ]; then
    echo "⏭️  已跳过全部 App Store 应用"
    finalize_results_if_owned
    exit 0
fi

if [ ! -f "$BREWFILE" ]; then
    echo "❌ 未找到 Brewfile：$BREWFILE"
    record_result "FAIL" "Brewfile" "文件不存在"
    finalize_results_if_owned
    exit 1
fi

MAS_LIST="$(mktemp -t mac-as-code-maslist.XXXXXX)"
parse_brewfile "$BREWFILE" >"$MAS_LIST"

MAS_TOTAL=0
while IFS='|' read -r type name id; do
    [ "$type" = "mas" ] || continue
    if plan_item_enabled mas "$name"; then
        MAS_TOTAL=$((MAS_TOTAL + 1))
    fi
done <"$MAS_LIST"

if [ "$MAS_TOTAL" -eq 0 ]; then
    echo "ℹ️  没有需要安装的 App Store 应用，跳过"
    record_result "SKIP" "mas" "无选中条目"
    rm -f "$MAS_LIST"
    finalize_results_if_owned
    exit 0
fi

if ! command -v brew >/dev/null 2>&1; then
    echo "❌ brew 未安装，请先运行 brew.sh"
    record_result "FAIL" "mas" "brew 未安装"
    rm -f "$MAS_LIST"
    finalize_results_if_owned
    exit 1
fi

# mas CLI 本身来自 Brewfile；若单独跑 mas.sh 时尚未安装，先装上
if ! command -v mas >/dev/null 2>&1; then
    echo "📦 未检测到 mas，正在安装..."
    if ! brew install --formula mas; then
        echo "❌ mas 安装失败"
        record_result "FAIL" "mas" "CLI 安装失败"
        rm -f "$MAS_LIST"
        finalize_results_if_owned
        exit 1
    fi
fi

# 全部已安装则无需登录门禁
NEED_INSTALL=0
while IFS='|' read -r type name id; do
    [ "$type" = "mas" ] || continue
    plan_item_enabled mas "$name" || continue
    if ! mas list 2>/dev/null | awk '{print $1}' | grep -qx "$id"; then
        NEED_INSTALL=1
        break
    fi
done <"$MAS_LIST"

if [ "$NEED_INSTALL" -eq 0 ]; then
    echo "✅ 选中的 App Store 应用均已安装"
    while IFS='|' read -r type name id; do
        [ "$type" = "mas" ] || continue
        plan_item_enabled mas "$name" || continue
        record_result "OK" "mas:$name" "已安装"
    done <"$MAS_LIST"
    rm -f "$MAS_LIST"
    finalize_results_if_owned
    exit 0
fi

##############################################
## 登录门禁：init 开头已确认则可跳过；单独运行 mas.sh 时仍询问
##############################################

if [ "${MAC_AS_CODE_MAS_READY:-}" = "1" ]; then
    echo "✅ App Store 登录已在装机开始时确认，直接安装"
else
    echo
    echo "📱 即将安装 $MAS_TOTAL 个 App Store 应用。"
    echo "   请先在 App Store 登录对应的 Apple 账号（脚本会打开 App Store）。"
    echo "   登录完成后回到此终端选择："
    echo "   - 直接按 Enter：继续安装全部 App Store 应用"
    echo "   - 输入 s 后按 Enter：跳过全部 App Store 应用（一个都不装）"
    open -a "App Store" 2>/dev/null || true

    while true; do
        printf "App Store 已登录？[Enter=继续 / s=全部跳过] > "
        if ! read -r answer; then
            answer="s"
        fi
        case "$answer" in
            s|S)
                SKIP_ALL_MAS=1
                break
                ;;
            *)
                break
                ;;
        esac
    done
fi

if [ "$SKIP_ALL_MAS" -eq 1 ]; then
    echo "⏭️  已跳过全部 App Store 应用安装"
    while IFS='|' read -r type name id; do
        [ "$type" = "mas" ] || continue
        plan_item_enabled mas "$name" || continue
        record_result "SKIP" "mas:$name" "未登录或用户选择跳过"
    done <"$MAS_LIST"
    rm -f "$MAS_LIST"
    finalize_results_if_owned
    exit 0
fi

install_mas_app() {
    name="$1"
    id="$2"
    index="$3"
    total="$4"

    if mas list 2>/dev/null | awk '{print $1}' | grep -qx "$id"; then
        echo "✅ [$index/$total] $name 已安装，跳过"
        record_result "OK" "mas:$name" "已安装"
        return 0
    fi

    echo "📱 [$index/$total] 正在安装：${name}（id: ${id}）"
    if mas install "$id" 2>/dev/null || mas get "$id"; then
        echo "✅ [$index/$total] $name 安装完成"
        record_result "OK" "mas:$name" "安装成功"
        return 0
    fi

    echo "❌ [$index/$total] 安装失败：$name"
    record_result "FAIL" "mas:$name" "安装失败（请确认已登录且账号可获取该应用）"
    FAIL_COUNT=$((FAIL_COUNT + 1))
    return 1
}

echo
echo "📦 逐个安装 App Store 应用..."
echo "   单个失败会记录并继续，不会整批中断。"

MAS_INDEX=0
while IFS='|' read -r type name id; do
    [ "$type" = "mas" ] || continue
    plan_item_enabled mas "$name" || continue
    MAS_INDEX=$((MAS_INDEX + 1))
    install_mas_app "$name" "$id" "$MAS_INDEX" "$MAS_TOTAL" || true
done <"$MAS_LIST"

rm -f "$MAS_LIST"
finalize_results_if_owned

if [ "$FAIL_COUNT" -gt 0 ]; then
    exit 1
fi
exit 0
