# Emmanuel's nur-packages

**My personal Nix packages, now available on  [NUR](https://github.com/nix-community/NUR)**

## Packages

### century-gothic

A Century Gothic font. For example...

```
fonts.fonts = with pkgs; [
  nur.repos.emmanuelrosa.century-gothic
];
```

### wingdings

A Wingdings font.

## NixOS Modules

### btrbk

This module sets up a systemd timer to create periodic snapshots of a BTRFS filesystem, using [btrbk](https://digint.ch/btrbk/index.html). Here's an example:

```
services.btrbk = {
  enable = true;
  volume = "/root/autosnapshots";
  config = ''
      timestamp_format long
      snapshot_preserve_min 5d 
      target_preserve_min 6m
      snapshot_dir snapshots/nixos
      snapshot_create onchange
      subvolume nixos/home
      subvolume nixos/rootfs
    '';
};
```
