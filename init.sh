echo "185.199.110.133 raw.githubusercontent.com" | sudo tee -a /etc/hosts
xcode-select --install

. ./defaults_config.sh
. ./defaults_dock.sh
. ./brew.sh
. ./mas.sh

# OhMyZsh
echo ">>> install OhMyZsh"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
