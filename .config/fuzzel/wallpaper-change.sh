#!/bin/bash
#
WALLPAPER_DIR="/home/fustigate/Pictures"

# Find all image files (jpg, jpeg, png, gif) sorted by modification time (newest first)
selected=$(cd "$WALLPAPER_DIR" && find . -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" \) -printf "%T@ %f\n" | sort -rn | cut -d' ' -f2- | fuzzel --dmenu)

if [ -z "$selected" ]; then
    exit 0
fi

echo "$selected"
swww img "/home/fustigate/Pictures/$selected" --transition-fps 30 --transition-type any --transition-duration 3

sed -i "s|^swww img .*|swww img \"/home/fustigate/Pictures/$selected\" --transition-fps 30 --transition-type any --transition-duration 3|" ~/.startup-wallpaper.sh  # changes wallpaper for next boot

sed -i "s|^image=.*|image=/home/fustigate/Pictures/$selected|" ~/.config/swaylock/config # changes lockscreen wallpaper
