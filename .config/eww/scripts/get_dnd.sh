#!/bin/bash

# Function to get the current DND status
get_dnd_status() {
    swaync-client -D | awk '{print $NF}'  # Get last word (true/false)
}

# Get and print the initial status
prev_status=$(get_dnd_status)
if [ "$prev_status" == "true" ]; then
    echo "True"  # DND is on, so no notifications
else
    echo "False"   # Notifications are enabled
fi

# Continuously check for changes
while true; do
    sleep 1  # Adjust this interval if needed

    current_status=$(get_dnd_status)
    if [ "$current_status" != "$prev_status" ]; then
        prev_status="$current_status"
        if [ "$current_status" == "true" ]; then
            echo "True"
        else
            echo "False"
        fi
    fi
done

