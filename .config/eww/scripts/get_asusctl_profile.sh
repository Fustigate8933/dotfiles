#!/bin/bash

CONFIG="$HOME/.asus_profile"

get_profile() {
    asusctl profile -p | awk -F'Active profile is ' '/Active profile is/ {print $2}'
}

last_profile=$(get_profile)
echo "$last_profile"

while true; do
    sleep 3
	current_profile=$(get_profile)
	if [ "$current_profile" != "$last_profile" ]; then
		echo "$current_profile"
		last_profile="$current_profile"
	fi
done

