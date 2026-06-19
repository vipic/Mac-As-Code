#!/bin/bash
set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
USER_CONFIG="$SCRIPT_DIR/configs/user.env"

echo "👤 配置 Git 全局用户信息..."

if [ ! -f "$USER_CONFIG" ]; then
    echo "⚠️  未找到 configs/user.env，跳过 Git 用户信息配置"
    echo "   可复制 configs/user.env.example 为 configs/user.env 后填写 GIT_USER_NAME 和 GIT_USER_EMAIL"
    exit 0
fi

GIT_USER_NAME=""
GIT_USER_EMAIL=""

# 本地个人配置文件，格式与 configs/user.env.example 保持一致。
# shellcheck source=/dev/null
source "$USER_CONFIG"

if [ -z "${GIT_USER_NAME:-}" ] || [ -z "${GIT_USER_EMAIL:-}" ]; then
    echo "⚠️  configs/user.env 中 Git 用户信息未填写完整，跳过 Git 用户信息配置"
    echo "   请填写 GIT_USER_NAME 和 GIT_USER_EMAIL"
    exit 0
fi

if ! command -v git &>/dev/null; then
    echo "⚠️  git 不可用，跳过 Git 用户信息配置"
    exit 0
fi

git config --global user.name "$GIT_USER_NAME"
git config --global user.email "$GIT_USER_EMAIL"

echo "✅ Git 全局用户信息已配置"
