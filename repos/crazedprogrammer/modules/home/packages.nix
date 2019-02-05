{ config, lib, pkgs, ... }:

{
  # Allow only these unfree packages.
  nixpkgs.config.allowUnfreePredicate = pkg:
    pkgs.lib.elem (builtins.parseDrvName pkg.name).name
    [ "steam" "steam-original" "steam-runtime" "technic-launcher" "astah-community" "teamspeak-client" ];

  environment.systemPackages = with pkgs; [
    # Basic tools
    wget curl jq bc loc p7zip fdupes pandoc texlive.combined.scheme-medium ls_extended

    # Version control
    git mercurial #darcs

    # Utilities
    xsel xclip gnome3.gnome-screenshot qemu calcurse binutils-unwrapped slop xdotool clang-tools hhpc stress xorg.xhost #kristvanity

    # Nix utilities
    nix-prefetch-git
    cabal2nix

    # Build systems
    pkgs.gnumake cmake gradle

    # Libraries
    SDL2 SDL2_image

    # Languages
    ghc lua5_3 cargo gcc luajit openjdk ruby nodejs-8_x
    sbcl (urn.override { useLuaJit = true; }) #haskellPackages.idris

    # Games
    multimc technic-launcher minetest gnome3.gnome-mines #dwarf-fortress
    love steam steam.run ccemux the-powder-toy chip8 riko4

    # Emulators
    dosbox stella snes9x-gtk vice dolphinEmuMaster

    # Terminal and editor
    kitty-wrapped neovim emacs-wrapped

    # Browsers
    firefox w3m qutebrowser #luakit

    # Web chat
    teamspeak_client #mumble

    # GTK+ and icon theme
    arc-theme paper-icon-theme

    # Office suite
    gnome3.gnome-calculator libreoffice-fresh

    # Visual editors
    gimp tiled

    # Multimedia
    audacity mpv gnome3.file-roller cli-visualizer-wrapped deadbeef ffmpeg projectm cava-wrapped zathura glmark2 #glava

    # Networking
    openvpn openssh update-resolv-conf sshfs mosh

    # WM utilities
    polybar-wrapped rofi-wrapped feh dunst-wrapped libnotify xtrlock-pam compton

    # Scripts
    dotfiles-bin

    # School
    plantuml arduino subversion fritzing plantuml #astah-community

    # System utilities
    pavucontrol polkit_gnome exfat-utils ntfs3g iotop bmon linuxPackages.perf picocom gotop htop
  ];
}
