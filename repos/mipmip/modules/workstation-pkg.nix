{ config, lib, pkgs, ... }:

{


  environment.systemPackages = with pkgs; [
    potrace
    weechat
    pandoc
    neofetch
    unstable.neovim
    ffmpeg
    alacritty
    go
    gox
    goreleaser

    hugo # needed for linny
    mipmip_pkg.fred # needed for linny

    vimHugeX
    #vim_configurable

    gitFull
  ]

  ++ (if pkgs.stdenv.isDarwin then [
     iterm2
  ]
  else [
    zathura
    x264

    docker
    docker-compose
    nextcloud-client
    gimp
    unstable.inkscape-with-extensions
    blender
    libreoffice
    spotify
    unstable.tdesktop
    keepassxc

    gthumb
    peek
    cinnamon.nemo
    evolution
    feh
    xclip
    nfs-utils
    gnome.gnome-tweaks
    baobab # GrandPerspective
    appimage-run
    #unstable.gnome.gpaste
    gnome.gpaste
    glib.dev
    glade

    whatsapp-for-linux
  ]);

}
