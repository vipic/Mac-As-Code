#!/bin/bash
set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
FAILED=0
MODE="all"

usage() {
    cat <<'EOF'
用法：bash doctor.sh [--pre|--post|--all]

  --pre   装机前：只检查会挡住 init 的硬门槛（CLT、git 等）
  --post  装机后：验收 Homebrew / mas / Oh My Zsh 等是否已就绪
  --all   全部检查（默认；单独排查时用）

bootstrap.sh 会依次调用 --pre 与 --post，避免装机前对「尚未安装的软件」误报。
EOF
}

while [ "$#" -gt 0 ]; do
    case "$1" in
        -h|--help)
            usage
            exit 0
            ;;
        --pre|--post|--all)
            MODE="${1#--}"
            shift
            ;;
        *)
            echo "❌ 未知参数：$1"
            usage
            exit 1
            ;;
    esac
done

pass() {
    echo "✅ $1"
}

warn() {
    echo "⚠️  $1"
}

fail() {
    echo "❌ $1"
    FAILED=1
}

section() {
    echo
    echo "==> $1"
}

check_prereqs() {
    section "macOS"
    if [ "$(uname -s)" = "Darwin" ]; then
        pass "当前系统是 macOS"
    else
        fail "当前脚本只支持 macOS"
    fi

    section "Xcode Command Line Tools"
    if xcode-select -p &>/dev/null; then
        pass "Xcode Command Line Tools 已安装：$(xcode-select -p)"
    else
        fail "未安装 Xcode Command Line Tools，请先运行：xcode-select --install"
    fi

    if command -v git &>/dev/null; then
        if git --version &>/dev/null; then
            pass "git 可用：$(git --version)"
        else
            fail "git 当前不可用，可能需要接受 Xcode 许可：sudo xcodebuild -license"
        fi
    else
        fail "git 不存在"
    fi

    section "Git 用户信息"
    USER_CONFIG="$SCRIPT_DIR/configs/user.env"
    if [ -f "$USER_CONFIG" ]; then
        GIT_USER_NAME=""
        GIT_USER_EMAIL=""
        # shellcheck source=/dev/null
        source "$USER_CONFIG"

        if [ -n "${GIT_USER_NAME:-}" ] && [ -n "${GIT_USER_EMAIL:-}" ]; then
            pass "configs/user.env 已填写 Git 用户信息"
        else
            warn "configs/user.env 中 Git 用户信息未填写完整，init.sh 会跳过 Git 用户信息配置"
        fi
    else
        warn "未找到 configs/user.env，init.sh 会跳过 Git 用户信息配置"
    fi

    section "Brewfile"
    if [ -f "$SCRIPT_DIR/Brewfile" ]; then
        pass "Brewfile 存在：$SCRIPT_DIR/Brewfile"
    else
        fail "未找到 Brewfile，无法按清单安装软件"
    fi
}

check_installed() {
    section "Homebrew"
    if command -v brew &>/dev/null; then
        pass "Homebrew 已安装：$(command -v brew)"
        if brew bundle list --all --file="$SCRIPT_DIR/Brewfile" &>/dev/null; then
            pass "Brewfile 可解析"
        else
            warn "Brewfile 解析检查未通过，可能是 Homebrew 缓存权限或网络问题"
        fi
    else
        fail "Homebrew 未安装"
    fi

    section "Mac App Store"
    if command -v mas &>/dev/null; then
        pass "mas 已安装"
        if mas_config="$(mas config 2>/dev/null)"; then
            pass "mas 可访问 App Store 配置信息"
            store_line="$(printf '%s\n' "$mas_config" | awk '/^store/ {print $NF; exit}')"
            region_line="$(printf '%s\n' "$mas_config" | awk '/^region/ {print $NF; exit}')"
            if [ -n "${store_line:-}" ] || [ -n "${region_line:-}" ]; then
                echo "   store: ${store_line:-unknown}, region: ${region_line:-unknown}"
            fi
        else
            warn "mas 无法读取 App Store 配置信息，Brewfile 中的 mas 应用可能无法安装"
        fi
    else
        fail "mas 未安装"
    fi

    section "Oh My Zsh"
    if [ -d "${ZSH:-$HOME/.oh-my-zsh}" ]; then
        pass "Oh My Zsh 已安装"
    else
        fail "Oh My Zsh 未安装"
    fi
}

case "$MODE" in
    pre)
        echo "🩺 doctor（装机前：硬门槛）"
        check_prereqs
        ;;
    post)
        echo "🩺 doctor（装机后：验收）"
        check_installed
        ;;
    all)
        echo "🩺 doctor（全部检查）"
        check_prereqs
        check_installed
        ;;
esac

echo
if [ "$FAILED" -eq 0 ]; then
    pass "doctor 检查完成"
else
    fail "doctor 检查发现需要先处理的问题"
fi

exit "$FAILED"
