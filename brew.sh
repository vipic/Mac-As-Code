#!/bin/bash
set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

#############################
## 安装 Homebrew 以及一些软件 ##
#############################

if ! command -v brew &>/dev/null; then
    echo "🍺 安装 Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # arm64 架构需要将 brew 加入环境变量
    if [ "$(uname -m)" = "arm64" ]; then
        echo "🔧 配置 Apple Silicon 环境..."
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
else
    echo "✅ Homebrew 已安装"
fi

##############################################
## 使用 Homebrew Bundle 安装 Brewfile 中的依赖
## tips: 备份当前电脑的依赖，使用 `brew bundle dump --describe --force --file="~/xxx/Brewfile"`
## 通过指定文件安装依赖，使用 `brew bundle --file="~/xxx/Brewfile"`
##############################################

echo "📦 安装 Brewfile 中的软件..."
brew bundle --file="$SCRIPT_DIR/Brewfile"
