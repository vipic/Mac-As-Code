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
menu-bar-visible|始终显示菜单栏（关闭自动隐藏）
fullscreen-hide-menu|全屏时隐藏菜单栏
measurement-cm|计量单位：厘米
temp-celsius|温度单位：摄氏度
disable-text-replacement|关闭系统文本替换（避免输入时被自动替换）
release-cmd-d|禁用 ⌘D 查字典快捷键（释放该组合键）
simple-password|清除账户密码策略（已清空则跳过；若仍有策略需管理员认证）
key-repeat-fast|加快按键重复速度（KeyRepeat=2）
key-repeat-delay-short|缩短按键重复前的延迟（InitialKeyRepeat=15）
finder-list-view|Finder 默认使用列表视图
finder-show-extensions|Finder 显示所有文件扩展名
clock-24h|强制 24 小时制（可能需注销/重启后生效）
trackpad-swipe-navigate|触控板双指左右滑：在页面间前进/后退
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
            # 策略已空时再执行 -clearaccountpolicies 仍会弹密码，非交互下会失败。
            # 先检查全局策略是否已无 <key>，已空则直接视为成功。
            if ! pwpolicy -getaccountpolicies 2>/dev/null | grep -q '<key>'; then
                echo "ℹ️  账户密码策略已为空，跳过清除"
                return 0
            fi
            echo "🔐 清除密码策略需要管理员认证…"
            if pwpolicy -clearaccountpolicies; then
                return 0
            fi
            # 终端密码失败时，尝试图形化提权（本机 GUI 可用时）
            if command -v osascript >/dev/null 2>&1; then
                osascript -e 'do shell script "pwpolicy -clearaccountpolicies" with administrator privileges'
                return $?
            fi
            return 1
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
