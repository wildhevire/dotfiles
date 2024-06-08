#!/bin/sh

wallpaperDir="$HOME/Pictures/Wallpapers"
TYPE="any"
FPS=60
DURATION=1
STEP=10
BEZIER="0.4,0.2,0.4,1.0"

selectedWallpaper="$wallpaperDir/$(ls $wallpaperDir | shuf -n 1)"

swwwParams="--transition-type $TYPE \
--transition-fps $FPS \
--transition-step $STEP \
--transition-duration $DURATION
--transition-bezier $BEZIER"
 
echo "$selectedWallpaper"
ln -sf "$selectedWallpaper" "$HOME/Pictures/current_wallpaper"


swww img $selectedWallpaper $swwwParams
sh $HOME/.config/hypr/scripts/pywal.sh
