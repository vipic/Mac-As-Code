##############################################
## 设置 Dock 相关
##############################################

# 设置 LaunchPad 显示行列数
defaults write com.apple.dock springboard-rows -int 10
defaults write com.apple.dock springboard-columns -int 8

# 重置 LaunchPad 布局
defaults write com.apple.dock ResetLaunchPad -int 1

# Dock 自动隐藏
defaults write com.apple.dock autohide -int 1

# Dock 位置
defaults write com.apple.dock orientation -string left

# Dock 大小
defaults write com.apple.dock mod-count -int 20

# Dock 图标大小
defaults write com.apple.dock largesize -int 128

# Dock 放大
defaults write com.apple.dock magnification -int 0

# Dock 最小化效果
defaults write com.apple.dock mineffect -string genie

# Dock 最小化到应用程序图标
defaults write com.apple.dock minimize-to-application -int 0

# Dock 正在打开应用程序的图标跳动
defaults write com.apple.dock launchanim -int 0

# Dock 显示隐藏动画时间
defaults write com.apple.dock autohide-time-modifier -int 0

# Dock 显示打开应用程序的指示灯
defaults write com.apple.dock show-process-indicators -int 1

# Dock 鼠标悬浮高亮
defaults write com.apple.dock mouse-over-hilite-stack -int 1

killall Dock
