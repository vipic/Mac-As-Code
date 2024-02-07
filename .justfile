# 通过命令行统一配置电脑的设置信息
set dotenv-load

# 显示当前的配置命令
default:
	@just -l

# 设置 launchPad 行列数
set-launchPad:
	defaults write com.apple.dock springboard-rows -int 10
	defaults write com.apple.dock springboard-columns -int 8
	defaults write com.apple.dock ResetLaunchPad -bool true
	killall Dock

# 禁止系统的文本替换功能
disable-text-replacement:
    defaults write -g WebAutomaticTextReplacementEnabled -bool false


# 释放快捷键 ⌘Command+D (需要重启)
release-cmd-d:
    defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 70 '<dict><key>enabled</key><false/></dict>'

# 支持简单密码
simple-password:
    pwpolicy -clearaccountpolicies

# Docker 瞬间显示和隐藏
docker-show-duration:
    defaults write com.apple.dock autohide-time-modifier -int 0
    killall Dock

# Dcoker 展开支持鼠标悬浮高亮
docker-hover-highlight:
    defaults write com.apple.dock mouse-over-hilite-stack -bool true
    killall Dock

# 追加 host 配置到 host 文件
append_multiple_to_host:
  @echo "$HOST_LINES" | sudo tee -a /etc/hosts

# 将当前配置备份到单独文件夹
backup:
    just backup_host
    just backup_zshrc

# 备份 host 文件
backup_host:
    mkdir -p /Users/$USER_NAME/backup
    cp /etc/hosts /Users/$USER_NAME/backup/hosts.bak

# 备份 zshrc 文件
backup_zshrc:
    mkdir -p /Users/$USER_NAME/backup
    cp /Users/$USER_NAME/.zshrc /Users/$USER_NAME/backup/zshrc.bak
