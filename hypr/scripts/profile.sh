#!/bin/sh

DEVICE=$(cat /sys/devices/virtual/dmi/id/product_family)

if [[ $DEVICE == "Swift 3" ]]; then
    hyprctl --batch "\
        keyword source ~/.config/hypr/monitor_laptop.conf ; \
        keyword source ~/.config/hypr/env_laptop.conf ; \
        keyword source ~/.config/hypr/input_laptop.conf; \
        keyword source ~/.config/hypr/gestures.conf;\
    "
else 
    
    hyprctl --batch "\
        keyword source ~/.config/hypr/monitor_desktop.conf ; \
        keyword source ~/.config/hypr/env_desktop.conf ; \
        keyword source ~/.config/hypr/input_desktop.conf; \
    "
fi

