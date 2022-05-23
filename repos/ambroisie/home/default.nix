{ ... }:
{
  imports = [
    ./bat
    ./bluetooth
    ./comma
    ./direnv
    ./discord
    ./documentation
    ./feh
    ./firefox
    ./flameshot
    ./gammastep
    ./gdb
    ./git
    ./gpg
    ./gtk
    ./htop
    ./jq
    ./mail
    ./mpv
    ./nix-index
    ./nm-applet
    ./packages
    ./pager
    ./power-alert
    ./ssh
    ./terminal
    ./tmux
    ./udiskie
    ./vim
    ./wm
    ./x
    ./xdg
    ./zathura
    ./zsh
  ];

  # First sane reproducible version
  home.stateVersion = "20.09";

  # Who am I?
  home.username = "ambroisie";

  # Start services automatically
  systemd.user.startServices = "sd-switch";
}
