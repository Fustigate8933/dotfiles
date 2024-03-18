#!/bin/bash

# Get the initial microphone mute status
initial_mute_status=$(pactl get-source-mute @DEFAULT_SOURCE@ | awk '/Mute:/ {print $2}')
if [ "$mute_status" == "yes" ]; then
	echo "False"
else
	echo "True"
fi

# Monitor for microphone mute status changes
pactl subscribe | rg --line-buffered "source" | while read -r _; do
    mute_status=$(pactl get-source-mute @DEFAULT_SOURCE@ | awk '/Mute:/ {print $2}')
    if [ "$mute_status" == "yes" ]; then
        echo "False"
    else
        echo "True"
    fi
done

