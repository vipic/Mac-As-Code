#!/bin/sh
set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib/common.sh
. "$SCRIPT_DIR/lib/common.sh"

######################################
## 系统设置（可按项勾选）
## 有的属性需要重启电脑之后生效
######################################

# 输出：id|说明（供多选 UI / 计划生成）
list_defaults_items() {
    cat <<'EOF'
menu-bar-visible|始终显示菜单栏（不自动隐藏）
fullscreen-hide-menu|全屏时隐藏菜单栏
measurement-cm|计量单位：厘米
temp-celsius|温度显示：摄氏度
disable-text-replacement|禁止系统文本替换（避免 macOS 误触发）
release-cmd-d|释放快捷键 ⌘D（查字典）
simple-password|允许简单密码（清除复杂密码策略）
key-repeat-fast|按键重复速度加快
key-repeat-delay-short|按键重复延迟缩短
finder-list-view|Finder 使用列表视图
finder-show-extensions|Finder 显示文件扩展名
clock-24h|日期显示 24 小时制（重启后生效）
trackpad-swipe-navigate|触控板双指水平滑动：前进/后退
EOF
}

if [ "${MAC_AS_CODE_LIST_CATALOG:-}" = "1" ]; then
    list_defaults_items
    exit 0
fi

apply_defaults_item() {
    case "$1" in
        menu-bar-visible)
            defaults write NSGlobalDomain _HIHideMenuBar -int 0
            ;;
        fullscreen-hide-menu)
            defaults write NSGlobalDomain AppleMenuBarVisibleInFullscreen -int 0
            ;;
        measurement-cm)
            defaults write NSGlobalDomain AppleMeasurementUnits -string Centimeters
            ;;
        temp-celsius)
            defaults write -g AppleTemperatureUnit -string Celsius
            ;;
        disable-text-replacement)
            # 参考：https://github.com/element-hq/element-web/issues/7155
            defaults write -g WebAutomaticTextReplacementEnabled -int 0
            ;;
        release-cmd-d)
            # 参考：https://apple.stackexchange.com/questions/22785
            defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 70 '<dict><key>enabled</key><false/></dict>'
            ;;
        simple-password)
            pwpolicy -clearaccountpolicies
            ;;
        key-repeat-fast)
            defaults write -g KeyRepeat -int 2
            ;;
        key-repeat-delay-short)
            defaults write -g InitialKeyRepeat -int 15
            ;;
        finder-list-view)
            defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
            ;;
        finder-show-extensions)
            defaults write NSGlobalDomain AppleShowAllExtensions -bool true
            ;;
        clock-24h)
            defaults write NSGlobalDomain AppleICUForce24HourTime -bool true
            ;;
        trackpad-swipe-navigate)
            defaults write NSGlobalDomain AppleEnableSwipeNavigateWithScrolls -bool true
            defaults write com.apple.AppleMultitouchTrackpad TrackpadHorizScroll -int 1
            defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadHorizScroll -int 1
            ;;
        *)
            echo "⚠️  未知系统设置项：$1"
            return 1
            ;;
    esac
}

init_results

echo "🔧 按勾选项应用系统设置..."
APPLIED=0
while IFS='|' read -r item_id item_label || [ -n "${item_id:-}" ]; do
    [ -n "${item_id:-}" ] || continue
    if plan_item_enabled defaults "$item_id"; then
        echo "  → ${item_label}"
        if apply_defaults_item "$item_id"; then
            record_result "OK" "defaults:$item_id" "$item_label"
            APPLIED=$((APPLIED + 1))
        else
            record_result "FAIL" "defaults:$item_id" "$item_label"
        fi
    else
        record_result "SKIP" "defaults:$item_id" "未选中"
    fi
done <<EOF
$(list_defaults_items)
EOF

if [ "$APPLIED" -gt 0 ]; then
    echo "🔄 重启 Finder 以应用设置..."
    killall Finder 2>/dev/null || true
else
    echo "ℹ️  未选中任何系统设置项"
fi

finalize_results_if_owned
exit 0
