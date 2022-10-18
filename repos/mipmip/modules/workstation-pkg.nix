{ config, lib, pkgs, ... }:

{


  environment.systemPackages = with pkgs; [
    potrace
    pandoc
    neofetch
    neovim
    ffmpeg
    alacritty
    go_1_18
    gox
    goreleaser

    hugo # needed for linny
    mipmip_pkg.fred # needed for linny
    mipmip_pkg.mip # Markdown in Preview

    vimHugeX
    #vim_configurable

    gitFull
    github-desktop
    gh # GitHub Cli
  ]

  ++ (if pkgs.stdenv.isDarwin then [
     iterm2
  ]
  else [
    zathura
    pdftk
    x264


    nextcloud-client
    gimp
    unstable.inkscape-with-extensions
    blender
    libreoffice
    spotify
    tdesktop
    keepassxc
    bitwarden

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
    gnome.gpaste
    gnome.gnome-screenshot
    vlc
    glib.dev
    glade
    protonmail-bridge

    whatsapp-for-linux
  ]);

}
