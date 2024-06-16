#!/bin/sh


wallpaper=$(readlink "$HOME/Pictures/current_wallpaper")


check_file() {
   
  if [ ! -f "$1" ]; then
    echo "File $1 not found!"
    exit 1
  fi
}

check_file "$wallpaper"

wal -i "$wallpaper" &
hyprctl notify -1 2000 "rgb(ff1ea3)" "Wallpaper:${wallpaper}" &
