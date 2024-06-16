#!/bin/sh

wallpaperDir="$HOME/Pictures/Wallpapers"
TYPE="any"
FPS=60
DURATION=1
STEP=4
BEZIER="0.4,0.2,0.4,1.0"

selectedWallpaper="$wallpaperDir/$(ls $wallpaperDir | shuf -n 1)"
extension="${selectedWallpaper##*.}"
filename="${selectedWallpaper%.*}"


swwwParams="--transition-type $TYPE \
--transition-fps $FPS \
--transition-step $STEP \
--transition-duration $DURATION
--transition-bezier $BEZIER"
 
echo "$selectedWallpaper"
ln -sf "$selectedWallpaper" "$HOME/Pictures/current_wallpaper"

killall mpvpaper && killall ffmpeg
if [[ $(file -b $selectedWallpaper) =~ ^'JPEG' || $(file -b $selectedWallpaper) =~ ^'PNG' ]]; then
    killall mpvpaper && killall ffmpeg
    swww img $selectedWallpaper $swwwParams &
else
    mpvpaper -o "no-audio --loop-playlist" '*' $selectedWallpaper &
fi

sh $HOME/.config/hypr/scripts/pywal.sh
