{ ... }:
{
  imports = [
    ./bat.nix
    ./bluetooth.nix
    ./direnv.nix
    ./documentation.nix
    ./feh.nix
    ./firefox
    ./flameshot.nix
    ./gammastep.nix
    ./git
    ./gpg.nix
    ./gtk.nix
    ./htop.nix
    ./jq.nix
    ./nm-applet.nix
    ./packages.nix
    ./pager.nix
    ./power-alert.nix
    ./secrets # Home-manager specific secrets
    ./ssh.nix
    ./terminal
    ./tmux.nix
    ./udiskie.nix
    ./vim
    ./wm
    ./x
    ./xdg.nix
    ./zathura.nix
    ./zsh
  ];

  # First sane reproducible version
  home.stateVersion = "20.09";

  # Who am I?
  home.username = "ambroisie";
}
