#!/bin/bash

STATE_FILE="/tmp/eww_stopwatch_state"
PID_FILE="/tmp/eww_stopwatch_pid"

format_time() {
    local total_seconds=$1
    local hours=$((total_seconds / 3600))
    local minutes=$(((total_seconds % 3600) / 60))
    local seconds=$((total_seconds % 60))
    printf "%02d:%02d:%02d" $hours $minutes $seconds
}

start_stopwatch() {
    if [ -f "$PID_FILE" ]; then
        exit 0
    fi
    
    local start_time
    start_time=$(date +%s)
    if [ -f "$STATE_FILE" ]; then
        local saved_time
        saved_time=$(cat "$STATE_FILE")
        start_time=$(($(date +%s) - saved_time))
    else
        echo "0" > "$STATE_FILE"
        start_time=$(date +%s)
    fi
    
    (
        while true; do
            local current_time
            current_time=$(date +%s)
            local elapsed=$((current_time - start_time))
            local formatted_time
            formatted_time=$(format_time $elapsed)
            eww update stopwatch_time="$formatted_time"
            sleep 1
        done
    ) &
    
    echo $! > "$PID_FILE"
    eww update stopwatch_running=true
}

stop_stopwatch() {
    if [ -f "$PID_FILE" ]; then
        local pid
        pid=$(cat "$PID_FILE")
        kill "$pid" 2>/dev/null
        wait "$pid" 2>/dev/null
        rm "$PID_FILE"
        
        local current_display
        current_display=$(eww get stopwatch_time)
        
        local hours minutes seconds
        hours=$(echo "$current_display" | cut -d: -f1)
        minutes=$(echo "$current_display" | cut -d: -f2)
        seconds=$(echo "$current_display" | cut -d: -f3)
        local total_seconds=$(( 10#$hours * 3600 + 10#$minutes * 60 + 10#$seconds ))
        echo "$total_seconds" > "$STATE_FILE"
    fi
    eww update stopwatch_running=false
}

reset_stopwatch() {
    stop_stopwatch
    rm -f "$STATE_FILE"
    eww update stopwatch_time="00:00:00"
    eww update stopwatch_running=false
}

case "$1" in
    toggle)
        if [ -f "$PID_FILE" ]; then
            stop_stopwatch
        else
            start_stopwatch
        fi
        ;;
    reset)
        reset_stopwatch
        ;;
    *)
        echo "Usage: $0 {toggle|reset}"
        exit 1
        ;;
esac

exit 0
