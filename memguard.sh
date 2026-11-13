#!/bin/bash
# ==============================================================================
# MemGuard - 4-Layer RAM Guardrail for Alpine Webtop on Render Free Tier
# Free Tier Limit: 512 MB | Hard Target: Keep container strictly under 490 MB
# ==============================================================================

TARGET_WARN_MB=380
TARGET_TRIM_MB=440
TARGET_EMERGENCY_MB=470

echo "[MemGuard] Initialized. Guarding RAM threshold under 490 MB..."

get_ram_usage_mb() {
    # Check cgroup v2
    if [ -f /sys/fs/cgroup/memory.current ]; then
        local b
        b=$(cat /sys/fs/cgroup/memory.current 2>/dev/null)
        if [ -n "$b" ] && [ "$b" -gt 0 ] 2>/dev/null; then
            echo $((b / 1024 / 1024))
            return
        fi
    fi

    # Check cgroup v1
    if [ -f /sys/fs/cgroup/memory/memory.usage_in_bytes ]; then
        local b
        b=$(cat /sys/fs/cgroup/memory/memory.usage_in_bytes 2>/dev/null)
        if [ -n "$b" ] && [ "$b" -gt 0 ] 2>/dev/null; then
            echo $((b / 1024 / 1024))
            return
        fi
    fi

    # Fallback to total resident memory of all processes
    local rss_kb
    rss_kb=$(ps -o rss= 2>/dev/null | awk '{sum+=$1} END {print sum}')
    if [ -n "$rss_kb" ]; then
        echo $((rss_kb / 1024))
        return
    fi

    echo 0
}

loop_count=0

while true; do
    sleep 4
    loop_count=$((loop_count + 1))

    RAM_MB=$(get_ram_usage_mb)

    # Periodic heartbeat log every ~2 minutes (30 loops * 4s = 120s)
    if [ $((loop_count % 30)) -eq 0 ]; then
        echo "[MemGuard-Heartbeat] Current RAM: ${RAM_MB} MB / 512 MB (Safe)"
    fi

    # Level 1: Warning
    if [ "$RAM_MB" -ge "$TARGET_WARN_MB" ] && [ "$RAM_MB" -lt "$TARGET_TRIM_MB" ]; then
        if [ $((loop_count % 5)) -eq 0 ]; then
            echo "[MemGuard-Warn] RAM usage elevated: ${RAM_MB} MB / 512 MB"
        fi
    fi

    # Level 2: Proactive Cache Trimming
    if [ "$RAM_MB" -ge "$TARGET_TRIM_MB" ]; then
        echo "[MemGuard-Trim] RAM reached ${RAM_MB} MB (> ${TARGET_TRIM_MB} MB). Dropping page cache..."
        sync 2>/dev/null
        echo 3 > /proc/sys/vm/drop_caches 2>/dev/null || true
    fi

    # Level 3: Emergency Process Interceptor (Prevent Render OOM Crash)
    if [ "$RAM_MB" -ge "$TARGET_EMERGENCY_MB" ]; then
        echo "[MemGuard-EMERGENCY] CRITICAL RAM SPIKE: ${RAM_MB} MB (> ${TARGET_EMERGENCY_MB} MB)!"
        
        # Find highest memory consumer owned by user abc (exclude desktop essentials)
        TARGET_PID=$(ps -u abc -o pid,rss,comm --sort=-rss 2>/dev/null | \
            grep -vE "xfce4-session|xfwm4|xfdesktop|xorg|kasm|s6|nginx|memguard|sh|bash" | \
            awk 'NR>1 {print $1; exit}')

        if [ -n "$TARGET_PID" ]; then
            PROC_NAME=$(ps -p "$TARGET_PID" -o comm= 2>/dev/null)
            echo "[MemGuard-Action] Terminating runaway process PID $TARGET_PID ($PROC_NAME) to save container!"
            kill -15 "$TARGET_PID" 2>/dev/null || true
            sleep 2
            kill -9 "$TARGET_PID" 2>/dev/null || true
        else
            echo "[MemGuard-Action] No individual user process found; executing emergency sync."
            sync 2>/dev/null
        fi
    fi
done
