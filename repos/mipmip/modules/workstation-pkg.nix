{ config, lib, pkgs, ... }:

{

  environment.systemPackages = with pkgs; [
    potrace
    weechat
    pandoc
    neofetch
    neovim
    ffmpeg
    alacritty
    go

    hugo # needed for linny
    mipmip_pkg.fred # needed for linny

    vimHugeX
    gitFull
  ]

  ++ (if pkgs.stdenv.isDarwin then [
     iterm2
  ]
  else [
    docker
    nextcloud-client
    gimp
    inkscape
    blender
    libreoffice
    spotify
    tdesktop
    keepassxc
    firefox

    peek
    cinnamon.nemo
    evolution
    feh
    xclip
    nfs-utils
    gnome.gnome-tweaks
    baobab # GrandPerspective
    appimage-run
    gnome.gpaste
  ]);

}
