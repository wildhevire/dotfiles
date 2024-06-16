
#!/bin/sh

DEVICE=$(cat /sys/devices/virtual/dmi/id/product_family)

if [[ $DEVICE == "Swift 3" ]]; then
    ln -sf ~/.config/hypr/workspace_laptop.conf ~/.config/hypr/workspace.conf
    ln -sf ~/.config/hypr/input_laptop.conf ~/.config/hypr/input.conf
    ln -sf ~/.config/hypr/env_laptop.conf ~/.config/hypr/env.conf
    
else
    ln -sf ~/.config/hypr/workspace_desktop.conf ~/.config/hypr/workspace.conf
    ln -sf ~/.config/hypr/input_desktop.conf ~/.config/hypr/input.conf
    ln -sf ~/.config/hypr/env_desktop.conf ~/.config/hypr/env.conf
fi
