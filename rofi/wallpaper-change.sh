#!/bin/bash
#
selected=$(echo "weathering_with_you-3.png
ado-rage.jpeg
power.jpeg
metro.gif
mario.gif
1134715.jpg
gojo.png
kusuriya1.png
kusuriya2.jpeg
frieren_camping.gif
frieren.jpeg
frieren_himmel1.jpg
frieren_himmel_stars.jpeg
frieren_tree.jpg" | rofi -dmenu)
echo "$selected"
swww img "/home/fustigate/Pictures/$selected" --transition-fps 30 --transition-type any --transition-duration 3

sed -i "s|^swww img .*|swww img \"/home/fustigate/Pictures/$selected\" --transition-fps 30 --transition-type any --transition-duration 3|" ~/.startup-wallpaper.sh  # changes wallpaper for next boot

sed -i "s|^image=.*|image=/home/fustigate/Pictures/$selected|" ~/.config/swaylock/config # changes lockscreen wallpaper

