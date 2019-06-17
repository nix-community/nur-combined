{ config, lib, pkgs, ... }:

{
  # Allow only these unfree packages.
  nixpkgs.config.allowUnfreePredicate = pkg:
    pkgs.lib.elem (builtins.parseDrvName pkg.name).name
    [ "steam" "steam-original" "steam-runtime" "factorio-alpha" "teamspeak-client" ];

  # Fix glava not finding config files.
  environment.etc."xdg/glava".source = "${pkgs.glava}/etc/xdg/glava";

  environment.systemPackages = with pkgs; [
    # Basic tools
    wget curl jq bc loc p7zip fdupes binutils-unwrapped ls_extended file parallel

    # Version control
    git #mercurial darcs

    # Utilities
    qemu pandoc graphviz flameGraph texlive.combined.scheme-medium clang-tools stress #kristvanity

    # X utilities
    xclip maim slop grim slurp pkgsUnstable.wf-recorder pkgsUnstable.wl-clipboard xdotool hhpc xorg.xhost

    # Nix utilities
    nix-du

    # Build systems
    gnumake cmake gradle

    # Libraries
    SDL2 SDL2_image

    # Languages
    lua5_3 cargo gcc luajit openjdk #ghc nodejs-8_x
    (urn.override { useLuaJit = true; })

    # Games
    multimc gnome3.gnome-mines #technic-launcher
    steam steam.run pkgsUnstable.ccemux the-powder-toy chip8 riko4

    # Emulators
    #dosbox stella snes9x-gtk vice dolphinEmuMaster

    # Terminal and editor
    kitty-wrapped neovim alacritty-wrapped

    # Browsers
    firefox w3m #luakit

    # Web chat
    teamspeak_client #mumble

    # GTK+ and icon theme (settings)
    arc-theme paper-icon-theme glib gsettings-desktop-schemas

    # Office suite
    gnome3.gnome-calculator libreoffice-fresh

    # Visual editors
    gimp #tiled

    # Multimedia
    (xfce.thunar.override { thunarPlugins = [ xfce.thunar-archive-plugin ]; }) xfce.mousepad xfce.ristretto
    audacity mpv gnome3.file-roller cli-visualizer-wrapped ffmpeg cava-wrapped glava zathura #projectm glava

    # Networking
    openssh networkmanagerapplet #openvpn update-resolv-conf sshfs

    # WM utilities
    polybar rofi-wrapped feh dunst-wrapped libnotify xtrlock-pam compton-latest i3lock i3blocks-wrapped

    # Scripts
    dotfiles-bin

    # School
    plantuml arduino subversion plantuml #fritzing astah-community

    # System utilities
    pavucontrol polkit_gnome exfat-utils ntfs3g iotop bmon linuxPackages.perf picocom gotop htop sysstat ncdu
  ] ++ (if builtins.pathExists /home/casper/.factorio.nix
    then lib.singleton (pkgsUnstable.factorio.override (import /home/casper/.factorio.nix))
    else [ ]);
}
