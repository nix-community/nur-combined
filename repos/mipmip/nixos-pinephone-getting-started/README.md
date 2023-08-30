build from any nix machine with:
```sh
nix build './#pinephone-img'
```

if nix complains about some "experimental features", then add to the host's nix config: `nix.extraOptions = "experimental-features = nix-command flakes";`

flash with:
```sh
sudo dd if=$(readlink result) of=/dev/sdb bs=4M oflag=direct conv=sync status=progress
```

then insert the SD card, battery into your pinephone and hold the power button for a few seconds until the power LED turns red.
after releasing the power button, the LED should turn yellow, then green. you'll see the "mobile NixOS" splash screen and then be dropped into a TTY login prompt.
