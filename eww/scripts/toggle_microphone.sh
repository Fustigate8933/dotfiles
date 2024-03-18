#!/bin/bash

# Get the current microphone mute status
current_mute_status=$(pactl get-source-mute @DEFAULT_SOURCE@ | awk '/Mute:/ {print $2}')

# Toggle the microphone mute status
if [ "$current_mute_status" == "yes" ]; then
    pactl set-source-mute @DEFAULT_SOURCE@ 0
    # echo "Microphone unmuted"
else
    pactl set-source-mute @DEFAULT_SOURCE@ 1
    # echo "Microphone muted"
fi

