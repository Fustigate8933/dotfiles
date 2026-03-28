#! /bin/bash
direction=$1
volume=$(pamixer --get-volume-human | tr -d '%')

if [ "$direction" = "down" ]; then
    pactl -- set-sink-volume 0 -5%
elif [ "$direction" = "up" ]; then
    if [ "$volume" -lt 146 ]; then
#        new_volume=$(( $(pactl list sinks | grep 'Volume:' | head -n 1 | sed -e 's/.* \([0-9]\+\)% .*/\1/') + 5 ))
#        pactl -- set-sink-volume 0 "$(( new_volume > 100 ? 100 : new_volume ))%"
      pactl -- set-sink-volume 0 +5%
    fi
fi

# This command might need further error handling
canberra-gtk-play -i message -V -15
1
