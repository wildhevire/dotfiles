
#!/bin/sh

DEVICE=$(cat /sys/devices/virtual/dmi/id/product_family)

if [[ $DEVICE == "Swift 3" ]]; then
    ln -sf ~/.config/hypr/workspace_laptop.conf ~/.config/hypr/workspace.conf
else
    ln -sf ~/.config/hypr/workspace_desktop.conf ~/.config/hypr/workspace.conf
fi
