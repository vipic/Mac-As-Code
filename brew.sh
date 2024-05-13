##############################################
## 安装 Homebrew 以及一些软件
##############################################

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)";

# 将 brew 加入环境变量 (arm64架构的需要这个)
arch=$(uname -m)

if [ "$arch" = "arm64" ]; then
    echo "执行arm架构的Mac上执行的操作"
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    echo "不是arm架构的Mac，不执行任何操作"
fi



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
    node
    rar
)

echo "installing binaries..."
for binary in "${binaries[@]}"; do
    brew install $binary
    if [ $? -ne 0 ]; then
        echo "Failed to install $binary"
    else
        echo "Successfully installed $binary"
    fi
done
brew cleanup
echo "Brew Upgrade"
brew upgrade

##############################################
## 有 UI 的应用
##############################################

apps=(
    google-chrome
    iina
    bartender
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
    obsidian
    squirrel
    jetbrains-toolbox
    # surge # 使用其他方式安装后再使用 brew 安装的话会报错停止，并且该仓库的大部分都要处于科学上网的环境下，所以第一步手动安装这个配置好，brew安装就可以排除
)

echo "installing cask apps..."
for app in "${apps[@]}"; do
    brew install --cask $app
    if [ $? -ne 0 ]; then
        echo "Failed to install $app"
    else
        echo "Successfully installed $app"
    fi
done

brew cleanup
