#!/bin/bash
set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

BREWFILE="$SCRIPT_DIR/Brewfile"
FAIL_COUNT=0

init_results

#############################
## 安装 Homebrew 以及一些软件 ##
#############################

if ! command -v brew &>/dev/null; then
    echo "🍺 安装 Homebrew..."
    if ! /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
        echo "❌ Homebrew 安装失败"
        record_result "FAIL" "Homebrew" "安装失败"
        finalize_results_if_owned
        exit 1
    fi

    # arm64 架构需要将 brew 加入环境变量
    if [ "$(uname -m)" = "arm64" ]; then
        echo "🔧 配置 Apple Silicon 环境..."
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
    record_result "OK" "Homebrew" "安装成功"
else
    echo "✅ Homebrew 已安装"
    record_result "OK" "Homebrew" "已安装"
fi

if [ ! -f "$BREWFILE" ]; then
    echo "❌ 未找到 Brewfile：$BREWFILE"
    record_result "FAIL" "Brewfile" "文件不存在"
    finalize_results_if_owned
    exit 1
fi

##############################################
## 逐个安装 Brewfile 中的依赖（失败继续，最后汇总）
## tips: 备份当前电脑的依赖，使用 `brew bundle dump --describe --force --file="~/xxx/Brewfile"`
##############################################

install_formula() {
    local name="$1"
    local index="$2"
    local total="$3"

    if brew list --formula "$name" &>/dev/null; then
        echo "✅ [$index/$total] $name 已安装，跳过"
        record_result "OK" "brew:$name" "已安装"
        return 0
    fi

    echo "⬇️  [$index/$total] 正在下载：$name"
    if ! brew fetch --formula --deps "$name"; then
        echo "❌ [$index/$total] 下载失败：$name"
        record_result "FAIL" "brew:$name" "下载失败"
        FAIL_COUNT=$((FAIL_COUNT + 1))
        return 1
    fi

    echo "📦 [$index/$total] 正在安装：$name"
    if ! brew install --formula "$name"; then
        echo "❌ [$index/$total] 安装失败：$name"
        record_result "FAIL" "brew:$name" "安装失败"
        FAIL_COUNT=$((FAIL_COUNT + 1))
        return 1
    fi

    echo "✅ [$index/$total] $name 安装完成"
    record_result "OK" "brew:$name" "安装成功"
    return 0
}

install_cask() {
    local name="$1"
    local index="$2"
    local total="$3"

    if brew list --cask "$name" &>/dev/null; then
        echo "✅ [$index/$total] $name 已安装，跳过"
        record_result "OK" "cask:$name" "已安装"
        return 0
    fi

    echo "⬇️  [$index/$total] 正在下载：$name"
    # brew fetch 的 --deps 与 --cask 互斥，cask 只拉自身安装包
    if ! brew fetch --cask "$name"; then
        echo "❌ [$index/$total] 下载失败：$name"
        record_result "FAIL" "cask:$name" "下载失败"
        FAIL_COUNT=$((FAIL_COUNT + 1))
        return 1
    fi

    echo "📦 [$index/$total] 正在安装：$name"
    if ! brew install --cask "$name"; then
        echo "❌ [$index/$total] 安装失败：$name"
        record_result "FAIL" "cask:$name" "安装失败"
        FAIL_COUNT=$((FAIL_COUNT + 1))
        return 1
    fi

    echo "✅ [$index/$total] $name 安装完成"
    record_result "OK" "cask:$name" "安装成功"
    return 0
}

# 先统计数量，再按 Brewfile 顺序安装（formula / cask）；mas 交给 mas.sh
FORMULA_TOTAL=0
CASK_TOTAL=0
while IFS='|' read -r type _name _id; do
    case "$type" in
        brew) FORMULA_TOTAL=$((FORMULA_TOTAL + 1)) ;;
        cask) CASK_TOTAL=$((CASK_TOTAL + 1)) ;;
    esac
done < <(parse_brewfile "$BREWFILE")

echo
echo "📦 按 Brewfile 逐个安装软件（formula ${FORMULA_TOTAL} + cask ${CASK_TOTAL}）..."
echo "   单个失败会记录并继续，不会整批中断。"

FORMULA_INDEX=0
CASK_INDEX=0
while IFS='|' read -r type name _id; do
    case "$type" in
        brew)
            FORMULA_INDEX=$((FORMULA_INDEX + 1))
            install_formula "$name" "$FORMULA_INDEX" "$FORMULA_TOTAL" || true
            ;;
        cask)
            CASK_INDEX=$((CASK_INDEX + 1))
            install_cask "$name" "$CASK_INDEX" "$CASK_TOTAL" || true
            ;;
    esac
done < <(parse_brewfile "$BREWFILE")

echo
echo "📱 处理 Brewfile 中的 App Store 应用..."
# mas.sh 复用同一份结果文件；失败不阻断后续 init 步骤
if ! bash "$SCRIPT_DIR/mas.sh"; then
    FAIL_COUNT=$((FAIL_COUNT + 1))
fi

finalize_results_if_owned

if [ "$FAIL_COUNT" -gt 0 ]; then
    exit 1
fi
exit 0
