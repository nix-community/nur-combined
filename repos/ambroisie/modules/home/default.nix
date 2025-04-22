{ ... }:
{
  imports = [
    ./aliases
    ./atuin
    ./bat
    ./bitwarden
    ./bluetooth
    ./calibre
    ./comma
    ./delta
    ./dircolors
    ./direnv
    ./discord
    ./documentation
    ./feh
    ./firefox
    ./flameshot
    ./fzf
    ./gammastep
    ./gdb
    ./git
    ./gpg
    ./gtk
    ./htop
    ./jq
    ./keyboard
    ./mail
    ./mpv
    ./nix
    ./nix-index
    ./nixpkgs
    ./nm-applet
    ./packages
    ./pager
    ./power-alert
    ./secrets
    ./ssh
    ./terminal
    ./tmux
    ./udiskie
    ./vim
    ./wget
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
