{ ... }:
{
  imports = [
    ./alacritty.nix
    ./bat.nix
    ./emacs.nix
    ./env.nix
    ./firefox.nix
    ./fish
    ./flameshot.nix
    ./git.nix
    ./laptop.nix
    ./rofi.nix
    ./secrets
    ./ssh.nix
    ./themes
    ./tmux.nix
    ./tridactyl.nix
    ./x
  ];

  home.stateVersion = "21.05";

  home.username = "alarsyo";
}
