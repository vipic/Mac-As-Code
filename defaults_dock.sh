#!/bin/bash
set -eu

###################
## 设置 Dock 相关 ##
###################

# 设置 LaunchPad 显示行列数
defaults write com.apple.dock springboard-rows -int 10
defaults write com.apple.dock springboard-columns -int 8

# 重置 LaunchPad 布局
defaults write com.apple.dock ResetLaunchPad -int 1

# Dock 自动隐藏
defaults write com.apple.dock autohide -int 1

# Dock 位置
defaults write com.apple.dock orientation -string left

# Dock 图标大小
defaults write com.apple.dock largesize -int 128

# Dock 不放大
defaults write com.apple.dock magnification -int 0

# Dock 最小化效果
defaults write com.apple.dock mineffect -string genie

# Dock 不最小化到应用程序图标
defaults write com.apple.dock minimize-to-application -int 0

# Dock 正在打开应用程序的图标不跳动
defaults write com.apple.dock launchanim -int 0

# Dock 显示/隐藏动画时间（0 = 即时，无动画）
defaults write com.apple.dock autohide-time-modifier -int 0

# Dock 显示打开应用程序的指示灯
defaults write com.apple.dock show-process-indicators -int 1

# Dock 不单独显示最近打开应用
defaults write com.apple.dock show-recents -int 0

# Dock 鼠标悬浮高亮
defaults write com.apple.dock mouse-over-hilite-stack -int 1

# Dock 设置触发角
# 右下角锁屏
defaults write com.apple.dock wvous-br-corner -int 13
# 左上角 显示桌面
defaults write com.apple.dock wvous-tl-corner -int 4
# 右上角和左下角 无操作
defaults write com.apple.dock wvous-tr-corner -int 1
defaults write com.apple.dock wvous-bl-corner -int 1

# 点击壁纸不展现桌面（Stage Manager 模式下默认行为是点壁纸展示桌面）
defaults write com.apple.WindowManager EnableStandardClickToShowDesktop -bool false

# 清空固定在 Dock 上的应用
defaults write com.apple.dock persistent-apps -array

# 固定 Apps（macOS 26 之前的 LaunchPad）和 Sublime Text
for app_path in "/System/Applications/Apps.app" "/Applications/Sublime Text.app"; do
    if [ -d "$app_path" ]; then
        defaults write com.apple.dock persistent-apps -array-add \
            "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>$app_path</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>"
    fi
done

killall Dock
