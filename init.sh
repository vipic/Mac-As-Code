# 需要补充一个预授权 sudo

xcode-select --install

. ./defaults_config.sh
. ./brew.sh
. ./mas.sh
. ./defaults_dock.sh

# OhMyZsh
echo ">>> install OhMyZsh"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
