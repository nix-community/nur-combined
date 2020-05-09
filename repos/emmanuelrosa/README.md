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

### electrum-personal-server

See the corresponding module in the NixOS Modules section below.

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
### electrum-personal-server

This module enables the [Electrum Personal Server](https://github.com/chris-belcher/electrum-personal-server), a maximally lightweight electrum server for a single user. It is configured as a systemd user service, so each user who wishes to use the service needs to create an Electrum Personal Server configuration file at `$HOME/.config/electrum-personal-server/config.ini`.
