#!/bin/bash

spaces() {
    CURRENT_WORKSPACE=$(xdotool get_desktop)
    WORKSPACE_WINDOWS=$(hyprctl workspaces -j | jq 'map({key: .id | tostring, value: .windows}) | from_entries')
    seq 1 10 | jq --argjson windows "${WORKSPACE_WINDOWS}" --argjson current "${CURRENT_WORKSPACE}" --slurp -Mc '
        map(tostring) | 
        map({id: ., windows: ($windows[.] // 0)}) |
        map(select(.windows > 0 or .id == ($current | tostring)))
    '
}

spaces
socat -u UNIX-CONNECT:/tmp/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock - | while read -r line; do
    spaces
done
