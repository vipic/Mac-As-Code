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
## 使用 Homebrew Bundle 安装 Brewfile 中的依赖
## tips: 备份当前电脑的依赖，使用 `brew bundle dump --describe --force --file="~/xxx/Brewfile"`
## 通过文件安装依赖，使用 `brew bundle --file="~/xxx/Brewfile"`
##############################################

brew bundle