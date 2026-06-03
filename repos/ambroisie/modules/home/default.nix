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
    ./trgui
    ./udiskie
    ./vim
    ./wget
    ./wm
    ./x
    ./xdg
    ./zathura
    ./zsh
  ];

  home.stateVersion = "26.05";

  # Start services automatically
  systemd.user.startServices = "sd-switch";
}
