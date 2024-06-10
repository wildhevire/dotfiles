#!/bin/sh

DEVICE=$(cat /sys/devices/virtual/dmi/id/product_family)

if [[ $DEVICE == "Swift 3" ]]; then
    ln -sf ~/.config/hypr/monitor_laptop.conf ~/.config/hypr/monitor.conf
else
    ln -sf ~/.config/hypr/monitor_desktop.conf ~/.config/hypr/monitor.conf
fi
