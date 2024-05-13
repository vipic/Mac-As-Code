# 原本以为可以使用修改 host 不翻墙访问 github 这个域名的，实际上不行
# echo "185.199.110.133 raw.githubusercontent.com" | sudo tee -a /etc/hosts

# 需要补充一个预授权 sudo

xcode-select --install

. ./defaults_config.sh
. ./brew.sh
. ./mas.sh
. ./defaults_dock.sh

# OhMyZsh
echo ">>> install OhMyZsh"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
