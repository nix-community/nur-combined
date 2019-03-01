{ config, lib, pkgs, ... }:

{
  # Allow only these unfree packages.
  nixpkgs.config.allowUnfreePredicate = pkg:
    pkgs.lib.elem (builtins.parseDrvName pkg.name).name
    [ "steam" "steam-original" "steam-runtime" "technic-launcher" "astah-community" "teamspeak-client" ];

  environment.systemPackages = with pkgs; [
    # Basic tools
    wget curl jq bc loc p7zip fdupes binutils-unwrapped ls_extended file parallel

    # Version control
    git #mercurial darcs

    # Utilities
    qemu pandoc texlive.combined.scheme-medium clang-tools stress #kristvanity

    # X utilities
    xsel xclip maim slop xdotool hhpc xorg.xhost

    # Nix utilities
    nix-prefetch-git

    # Build systems
    gnumake cmake gradle

    # Libraries
    SDL2 SDL2_image

    # Languages
    lua5_3 cargo gcc luajit openjdk #ghc nodejs-8_x
    (urn.override { useLuaJit = true; })

    # Games
    multimc gnome3.gnome-mines #technic-launcher
    steam steam.run ccemux the-powder-toy chip8 riko4

    # Emulators
    #dosbox stella snes9x-gtk vice dolphinEmuMaster

    # Terminal and editor
    kitty-wrapped neovim

    # Browsers
    firefox w3m #luakit

    # Web chat
    teamspeak_client #mumble

    # GTK+ and icon theme
    arc-theme paper-icon-theme

    # Office suite
    gnome3.gnome-calculator libreoffice-fresh

    # Visual editors
    gimp #tiled

    # Multimedia
    audacity mpv gnome3.file-roller cli-visualizer-wrapped ffmpeg cava-wrapped zathura #projectm glava

    # Networking
    openssh #openvpn update-resolv-conf sshfs

    # WM utilities
    polybar-wrapped rofi-wrapped feh dunst-wrapped libnotify xtrlock-pam compton-latest

    # Scripts
    dotfiles-bin

    # School
    plantuml arduino subversion plantuml #fritzing astah-community

    # System utilities
    pavucontrol polkit_gnome exfat-utils ntfs3g iotop bmon linuxPackages.perf picocom gotop htop
  ];
}
