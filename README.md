To install edid
- Copy the edid file to `/usr/lib/firmware/edid`
- Add to edid to kernel param in boot loader enties
    - Identify the unoccupied GPU port with
    ```sh
    for p in /sys/class/drm/*/status; do con=${p%/status}; echo -n "${con#*/card?-}: "; cat $p; done
    ```
    - Add edid to kernel parameter in boot loader 
    ```
    drm.edid_firmware=DP-3:edid/xiaomi video=DP-3:e
    ```
    Change the DP-3 to the GPU port
- Add edid blob to `/etc/mkinitcpio.conf'
- Regenerate initramfs
    `# mkinitcpio -P`
