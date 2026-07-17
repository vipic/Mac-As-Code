#!/bin/bash
# 共用辅助函数：结果记录与 Brewfile 解析。
# 由 init.sh / brew.sh / mas.sh source，不要直接执行。

# 初始化结果文件。若由 init.sh 导出 MAC_AS_CODE_RESULTS，则复用（不清空）；否则自建。
init_results() {
    if [ -z "${MAC_AS_CODE_RESULTS:-}" ]; then
        MAC_AS_CODE_RESULTS="$(mktemp -t mac-as-code.XXXXXX)"
        MAC_AS_CODE_RESULTS_OWNED=1
        export MAC_AS_CODE_RESULTS
        : >"$MAC_AS_CODE_RESULTS"
    else
        MAC_AS_CODE_RESULTS_OWNED=0
    fi
}

# 追加一条结果。status: OK | FAIL | SKIP
record_result() {
    local status="$1"
    local item="$2"
    local detail="${3:-}"

    if [ -z "${MAC_AS_CODE_RESULTS:-}" ]; then
        return 0
    fi
    printf '%s\t%s\t%s\n' "$status" "$item" "$detail" >>"$MAC_AS_CODE_RESULTS"
}

# 打印成功 / 失败 / 跳过汇总
print_results_summary() {
    local file="${1:-${MAC_AS_CODE_RESULTS:-}}"
    local ok_count=0 fail_count=0 skip_count=0
    local status item detail

    if [ -z "$file" ] || [ ! -f "$file" ]; then
        echo
        echo "ℹ️  无结果可汇总"
        return 0
    fi

    echo
    echo "================ 执行结果汇总 ================"

    if grep -q $'^OK\t' "$file" 2>/dev/null; then
        echo
        echo "✅ 成功："
        while IFS=$'\t' read -r status item detail; do
            [ "$status" = "OK" ] || continue
            ok_count=$((ok_count + 1))
            if [ -n "$detail" ]; then
                # bash 3.2：多字节字符紧贴 $var 会被误解析，必须用 ${var}
                echo "  - ${item}（${detail}）"
            else
                echo "  - ${item}"
            fi
        done <"$file"
    fi

    if grep -q $'^FAIL\t' "$file" 2>/dev/null; then
        echo
        echo "❌ 失败："
        while IFS=$'\t' read -r status item detail; do
            [ "$status" = "FAIL" ] || continue
            fail_count=$((fail_count + 1))
            if [ -n "$detail" ]; then
                echo "  - ${item}（${detail}）"
            else
                echo "  - ${item}"
            fi
        done <"$file"
    fi

    if grep -q $'^SKIP\t' "$file" 2>/dev/null; then
        echo
        echo "⏭️  跳过："
        while IFS=$'\t' read -r status item detail; do
            [ "$status" = "SKIP" ] || continue
            skip_count=$((skip_count + 1))
            if [ -n "$detail" ]; then
                echo "  - ${item}（${detail}）"
            else
                echo "  - ${item}"
            fi
        done <"$file"
    fi

    echo
    echo "统计：成功 ${ok_count}，失败 ${fail_count}，跳过 ${skip_count}"
    echo "=============================================="

    if [ "$fail_count" -gt 0 ]; then
        return 1
    fi
    return 0
}

# 若结果文件由本脚本创建，则打印汇总并清理
finalize_results_if_owned() {
    if [ "${MAC_AS_CODE_RESULTS_OWNED:-0}" = "1" ] && [ -n "${MAC_AS_CODE_RESULTS:-}" ]; then
        print_results_summary "$MAC_AS_CODE_RESULTS"
        rm -f "$MAC_AS_CODE_RESULTS"
        unset MAC_AS_CODE_RESULTS
        MAC_AS_CODE_RESULTS_OWNED=0
    fi
}

# 去掉行首尾空白
trim() {
    local s="$1"
    s="${s#"${s%%[![:space:]]*}"}"
    s="${s%"${s##*[![:space:]]}"}"
    printf '%s' "$s"
}

# 解析 Brewfile，按出现顺序输出：type|name|id
# type: brew | cask | mas；mas 的 id 为 App Store ADAM ID，其余为空
parse_brewfile() {
    local brewfile="$1"
    local line name id

    while IFS= read -r line || [ -n "$line" ]; do
        line="${line%%#*}"
        line="$(trim "$line")"
        [ -z "$line" ] && continue

        case "$line" in
            brew\ \"*)
                name="${line#brew \"}"
                name="${name%%\"*}"
                printf 'brew|%s|\n' "$name"
                ;;
            cask\ \"*)
                name="${line#cask \"}"
                name="${name%%\"*}"
                printf 'cask|%s|\n' "$name"
                ;;
            mas\ \"*)
                name="${line#mas \"}"
                name="${name%%\"*}"
                id=""
                if [[ "$line" =~ id:[[:space:]]*([0-9]+) ]]; then
                    id="${BASH_REMATCH[1]}"
                fi
                if [ -n "$id" ]; then
                    printf 'mas|%s|%s\n' "$name" "$id"
                fi
                ;;
        esac
    done <"$brewfile"
}
