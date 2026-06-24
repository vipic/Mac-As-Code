#!/bin/bash
set -eu

######################################
## 设置修改，有的属性需要重启电脑之后生效 ##
######################################

# 始终显示菜单栏（不自动隐藏）
defaults write NSGlobalDomain _HIHideMenuBar -int 0

# 全屏时隐藏菜单栏
defaults write NSGlobalDomain AppleMenuBarVisibleInFullscreen -int 0

defaults write NSGlobalDomain AppleMeasurementUnits -string Centimeters

# 温度显示摄氏度
defaults write -g AppleTemperatureUnit -string Celsius

# 禁止 mac 系统的文本替换 [参考链接](https://github.com/element-hq/element-web/issues/7155) 和他类似，之所以不删除 macOS 上的文本替换，是因为文本替换会在 iOS 和 macOS 之间同步，iOS 端会将替换内容上到候选词里面，不会误触。但是在 macOS 上直接就触发了替换，非常影响使用。
defaults write -g WebAutomaticTextReplacementEnabled -int 0

# 释放快捷键 ⌘Command+D（查字典）[参考链接](https://apple.stackexchange.com/questions/22785)
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 70 '<dict><key>enabled</key><false/></dict>'

# 允许简单密码（家庭电脑不需要复杂密码策略）
pwpolicy -clearaccountpolicies

# 按键重复速度（长按删除键时字符重复间隔，越小越快。2 = 30ms，为系统偏好设置滑条允许的最快值；1 = 15ms 可通过 defaults write 设置）
defaults write -g KeyRepeat -int 2

# 按键重复延迟（按住一个字母后等多久开始连续输入，越小越短）
defaults write -g InitialKeyRepeat -int 15

# Finder 使用列表视图
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# Finder 显示文件扩展名
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# 日期显示采用 24 小时制（重启电脑生效）
defaults write NSGlobalDomain AppleICUForce24HourTime -bool true

# Trackpad 双指水平滑动 = 在页面间滑动（浏览器前进/后退等）
defaults write NSGlobalDomain AppleEnableSwipeNavigateWithScrolls -bool true
defaults write com.apple.AppleMultitouchTrackpad TrackpadHorizScroll -int 1
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadHorizScroll -int 1

echo "🔄 重启 Finder 以应用设置..."
killall Finder
