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

# 禁止 mac 系统的文本替换 [参考链接](https://github.com/element-hq/element-web/issues/7155) 和他类似，之所以不删除 macOS 上的文本替换，是因为文本替换会在 iOS 和 macOS 之间同步，iOS 端会将替换内容上到候选词里面，不会误触。但是在 macOS 上直接就触发了替换，非常影响使用。
defaults write -g WebAutomaticTextReplacementEnabled -int 0

# 释放快捷键 ⌘Command+D (需要重启) [参考链接](https://apple.stackexchange.com/questions/22785/how-do-i-disable-the-command-control-d-word-definition-keyboard-shortcut-in-os-x)
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 70 '<dict><key>enabled</key><false/></dict>'

# 支持简单密码
pwpolicy -clearaccountpolicies

# 按键重复速度(长按删除键的时候这个的执行速度，越短越快)
defaults write -g KeyRepeat -int 2

# 按键重复延迟(按住一个字母后等多久会变成一直输入)
defaults write -g InitialKeyRepeat -int 15

# Finder 使用 list 视图
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# Finder 显示文件扩展名
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# 日期显示采用 24 小时制
defaults write NSGlobalDomain AppleICUForce24HourTime -bool true

killall Finder