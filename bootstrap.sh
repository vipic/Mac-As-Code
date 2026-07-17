#!/bin/bash
set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

SKIP_DOCTOR=0
INIT_FROM=""

usage() {
    cat <<'EOF'
用法：bash bootstrap.sh [--from <步骤名>] [--skip-doctor]

装机管线（本仓库 / GitHub 可提交的配置）：
  1. doctor --pre   装机前硬门槛（CLT、git、Brewfile 等）
  2. init           系统设置 + Brewfile 软件 + Oh My Zsh + Dock
  3. doctor --post  装机后验收（brew / mas / Oh My Zsh）

个人数据的备份 / 恢复是另一条管线，不走本脚本：
  备份：bash backup.sh
  恢复：进入快照目录后 bash restore.sh

示例：
  bash bootstrap.sh
  bash bootstrap.sh --from brew
  bash bootstrap.sh --skip-doctor
EOF
}

while [ "$#" -gt 0 ]; do
    case "$1" in
        -h|--help)
            usage
            exit 0
            ;;
        --skip-doctor)
            SKIP_DOCTOR=1
            shift
            ;;
        --from)
            if [ -z "${2:-}" ]; then
                echo "❌ --from 需要指定步骤名：defaults, git, brew, zsh, dock"
                exit 1
            fi
            INIT_FROM="$2"
            shift 2
            ;;
        *)
            echo "❌ 未知参数：$1"
            usage
            exit 1
            ;;
    esac
done

FAIL_COUNT=0

run_phase() {
    local title="$1"
    shift

    echo
    echo "======== ${title} ========"
    if "$@"; then
        echo "✅ ${title}：完成"
        return 0
    fi

    echo "⚠️  ${title}：失败（已记录，继续后续阶段）"
    FAIL_COUNT=$((FAIL_COUNT + 1))
    return 1
}

if [ "$SKIP_DOCTOR" -eq 0 ]; then
    run_phase "装机前检查" bash "$SCRIPT_DIR/doctor.sh" --pre || true
fi

if [ -n "$INIT_FROM" ]; then
    run_phase "初始化安装" bash "$SCRIPT_DIR/init.sh" --from "$INIT_FROM" || true
else
    run_phase "初始化安装" bash "$SCRIPT_DIR/init.sh" || true
fi

if [ "$SKIP_DOCTOR" -eq 0 ]; then
    run_phase "装机后检查" bash "$SCRIPT_DIR/doctor.sh" --post || true
fi

echo
if [ "$FAIL_COUNT" -eq 0 ]; then
    echo "✅ bootstrap 全部完成"
    echo "如需恢复个人数据：进入 backup.sh 生成的快照目录，执行 bash restore.sh"
    exit 0
fi

echo "⚠️  bootstrap 结束，但仍有 ${FAIL_COUNT} 个阶段失败；请根据上方输出与 ~/Library/Logs/mac-as-code/ 中的 init 报告处理。"
exit 1
