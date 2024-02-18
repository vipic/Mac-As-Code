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

# Dock 不单独显示最近打开应用
 defaults write com.apple.dock show-recents -int 0

# Dock 鼠标悬浮高亮
defaults write com.apple.dock mouse-over-hilite-stack -int 1

# Dock 设置触发角
# 右下 lock screen
defaults write com.apple.dock wvous-br-corner -int 13
# 左上 显示桌面
defaults write com.apple.dock wvous-tl-corner -int 4
# 左下和右上空白
defaults write com.apple.dock wvous-tr-corner -int 1
defaults write com.apple.dock wvous-bl-corner -int 1

# 固定在 Dock 的應用
# clear items
defaults write com.apple.dock persistent-apps -array

for dockItem in {/System/Applications/{"Launchpad.app"}; do
  defaults write com.apple.dock persistent-apps -array-add '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>'$dockItem'</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>'
done

killall Dock
