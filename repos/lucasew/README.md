# Dotfiles and Nix/NixOS settings

- home-manager: dotfile manager, runs as a configuration.nix extension

- the way it is organized its not necessary to place the nix files in the default locations like

    - `/etc/nixos/configuration.nix`
    - `~/.config/nixpkgs/home.nix`

- a few overlays for custom packages like stremio and shiginima launcher

- multiple interchangeable graphical environments
    - i3 + xfce: working nice, unable to skip music locked (workaround using kdeconnect xD), the bar is still the default
    - gnome: now is what I am using, working nice, also in unstable there is a new lockscreen (GDM) that I think is better than the old
    - xfce: working nice too
    - kde: works but I haven't played much yet

- modular fashion: home modules are searched when the config files loads, you just create a file in home directory using home-manager 
module structure and nix imports it automagically, same for `machine/acer`
    
- machines referenced:
    - acer: my main laptop. Acer A315-51-51SL 6GB RAM 240GB SSD Dual booted with Windows 10

- not tested
    - bootstrap in a new machine, should regenerate the configuration.nix and hardware.nix and adapt in a new device

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
