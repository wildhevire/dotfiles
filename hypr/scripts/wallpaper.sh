#!/bin/sh
swww img ~/Pictures/Wallpapers/$(ls ~/Pictures/Wallpapers/ | shuf -n 1) \
--transition-type center \
--transition-fps 60 \
--transition-step 10 \
--transition-duration 1 

