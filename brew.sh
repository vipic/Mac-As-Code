##############################################
## 安装 Homebrew 以及一些软件
##############################################

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)";

# 将 brew 加入环境变量
echo 'eval ,"$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"

##############################################
## 命令行应用
##############################################

binaries=(
    tree
    pnpm
    yarn
    just
    htop
    mas
    http-server
    rar
    node
)

echo "installing binaries..."
brew install "${binaries[@]}"
brew cleanup
echo "Brew Upgrade"
brew upgrade

##############################################
## 有 UI 的应用
##############################################

apps=(
    orbstack
    google-chrome
    iina
    discord
    arc
    iterm2
    postman
    cleanshot
    raycast
    keyboard-maestro
    sublime-text
    logitech-options
    textexpander
    qBittorrent
    telegram
    anki
    devonthink
    ppduck
    skim
    jetbrains-toolbox
    # surge # 使用其他方式安装后再使用 brew 安装的话会报错停止
)

echo "installing cask apps..."
brew install --cask "${apps[@]}"
brew cleanup
