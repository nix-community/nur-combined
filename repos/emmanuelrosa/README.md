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

### er-wallpaper

My custom script to set wallpaper and color schemes. It's simply a wrapper for `pywal` and `betterlockscreen`.

### electrum-hardened

The (Electrum)[https://electrum.org] wallet executed in a restricted environment using [Bubblewrap)[https://github.com/containers/bubblewrap].

More specifically, Electrum is executed in a Linux container with no network access and with limited access to the filesystem. This makes it more difficult for Electrum to (perhaps accidently) leak information. In short, it prevents Electrum from using public Electrum servers. And it also prevents Electrum from accessing BTC price APIs. Although the latter can probably be fixed.

It's expected that you use `electrum-hardened` with `electrum-personal-server`; It's the only network access permitted. In addition, if the directory `$HOME/tnxs` exists, it's bind-mounted into the container; This allows the transfer of files, such as partially-signed transactions, between the host and the container.

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
