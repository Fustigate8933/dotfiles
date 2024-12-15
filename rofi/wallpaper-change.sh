#!/bin/bash
#
selected=$(echo "weathering_with_you-3.png
ado-rage.jpeg
power.jpeg
metro.gif
dungeon-meshi.jpg
lian.jpg
lian_no_watermark.png
mario.gif
1134715.jpg
gojo.png
jjk.png
kusuriya1.png
kusuriya2.jpeg
frieren_camping.gif
frierenkid.jpeg
frieren.jpeg
frieren_himmel1.jpg
frieren_himmel_stars.jpeg
frieren_warm.jpg
clone.png
frieren_sleeping.jpg
frieren_suitcase.jpeg
frieren_tree_clipped.jpg
frieren_meshi.png
mushoku.jpg
zaraki.jpg
shibuya.jpg
shocked.jpg
orsted.jpg
snowman.jpg
mushokutensei.jpg
pixelroom.gif
torii.gif
sylphy_sleep.jpg
konbini.jpg
osaka.jpg
bluebox.png
balcony.jpeg
trainstation.gif
rainystreet.gif
snowtrain.jpg
konbini_live.gif
osaka_tower.jpg
samurai.jpg
roadtrip.jpeg
reading.png" | rofi -dmenu)
echo "$selected"
swww img "/home/fustigate/Pictures/$selected" --transition-fps 30 --transition-type any --transition-duration 3

sed -i "s|^swww img .*|swww img \"/home/fustigate/Pictures/$selected\" --transition-fps 30 --transition-type any --transition-duration 3|" ~/.startup-wallpaper.sh  # changes wallpaper for next boot

sed -i "s|^image=.*|image=/home/fustigate/Pictures/$selected|" ~/.config/swaylock/config # changes lockscreen wallpaper

