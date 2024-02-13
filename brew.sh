##############################################
## 安装 Homebrew 以及一些软件
##############################################

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

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
    surge
    raycast
    keyboard-maestro
    jetbrains-toolbox
    sublime-text
    logitech-options
    textexpander
    qBittorrent
    telegram
    blender
    anki
    devonthink
    ppduck
    skim
)

echo "installing cask apps..."
brew install --cask "${apps[@]}"
brew cleanup
