##############################################
## 设置全局属性，有的属性可能是和用户相关或者重启电脑等操作，不保证全部有效
##############################################

# 自动隐藏菜单栏
defaults write NSGlobalDomain _HIHideMenuBar -int 0

# 应用全屏的时候菜单栏是否可见
defaults write NSGlobalDomain AppleMenuBarVisibleInFullscreen -int 0

defaults write NSGlobalDomain AppleMeasurementUnits -string Centimeters

# 温度显示摄氏度
defaults write -g AppleTemperatureUnit -string Celsius

# 禁止 mac 系统的文本替换
defaults write -g WebAutomaticTextReplacementEnabled -int 0

# 释放快捷键 ⌘Command+D (需要重启)
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 70 '<dict><key>enabled</key><false/></dict>'

# 支持简单密码
pwpolicy -clearaccountpolicies


# Finder 使用 list 视图
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# Finder 显示文件扩展名
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

killall Finder