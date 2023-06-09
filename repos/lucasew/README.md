# Dotfiles and Nix/NixOS settings

[![built with nix](https://builtwithnix.org/badge.svg)](https://builtwithnix.org)

- home-manager: dotfile manager, runs as a configuration.nix extension

- the way it is organized its not necessary to place the nix files in the default locations like

    - `/etc/nixos/configuration.nix`
    - `~/.config/nixpkgs/home.nix`

- multiple interchangeable graphical environments
    - i3: daily driver, working nice, playback buttons works when locked
    - gnone, xfce and kde: not using anymore, may delete later

- machines referenced:
    - riverwood: my main laptop, Acer A315-51-51SL 12GB RAM 1TB SSD dual booted with windows 10 (i think)
    - whiterun: my battlestation, Ryzen 5600G, 32GB RAM 1TB SSD + 2x1TB DVR HDDs + a RTX 3060 in the future
    - ravenrock: a machine in the cloud, it's provisioned using terraform from `infra/turbo/gcp.tf`

- licence
    - nothing special
    - don't blame me
    - have fun

- suggestions?
    - open a issue
    - let's learn together :smile:

- NixOS > Arch
    - change my mind
    - (yes, I have used arch btw for around 1 year, it's a good distro but NixOS is better for my workflow)
    - `nix-shell` rocks
    - the possibility of rollback at any time in a simple way, even if the distro fails to boot, is like magic
    - you can also replicate very precisely your configuration on another machine, but only if that is defined in Nix, imperative settings are left behind
    - not perfect but it's really easy to feel physical pain using something else or packaging software that tries to download stuff at build time
