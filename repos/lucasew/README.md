# Dotfiles and Nix/NixOS settings

[![built with nix](https://builtwithnix.org/badge.svg)](https://builtwithnix.org)

- home-manager: dotfile manager, runs as a configuration.nix extension

- the way it is organized its not necessary to place the nix files in the default locations like

    - `/etc/nixos/configuration.nix`
    - `~/.config/nixpkgs/home.nix`

- a few overlays for custom packages like stremio and shiginima launcher

- multiple interchangeable graphical environments
    - i3 + xfce: working nice, using polybar and the playback buttons works when locked
    - gnome: it works but I am not using anymore
    - xfce: working nice. I use the XFCE daemons on the i3 flavor
    - kde: works, not so nice and I am not using it

module structure and nix imports it automagically, same for `machine/acer`
    
- machines referenced:
    - acer: my main laptop. Acer A315-51-51SL 6GB RAM 240GB SSD Dual booted with Windows 10
    - vps: a f1-micro VPS running on Google Cloud Platform (for free)
    - android: a Redmi Note 5 (whyred), it's not running NixOS but I want to add some scripts I use with it

- not tested
    - bootstrap in a new machine, should regenerate the configuration.nix and hardware.nix and adapt in a new device. I will do this on demand

- licence
    - nothing special
    - don't blame me
    - have fun

- suggestions?
    - open a issue
    - let's learn together :smile:

- NixOS > Arch
    - change my mind
    - (yes, I have used arch btw for around 1 year, it's a good distro but NixOS is better)
    - `nix-shell` rocks
    - the possibility of rollback at any time in a simple way, even if the distro fails to boot, is like magic
    - you can also replicate very precisely your configuration on another machine, but only if that is defined in Nix, imperative settings are left behind
