{ ... }:
{
  imports = [
    ./bat.nix
    ./direnv.nix
    ./documentation.nix
    ./git
    ./gpg.nix
    ./htop.nix
    ./jq.nix
    ./packages.nix
    ./pager.nix
    ./secrets # Home-manager specific secrets
    ./ssh.nix
    ./tmux.nix
    ./vim
    ./xdg.nix
    ./zsh
  ];

  # First sane reproducible version
  home.stateVersion = "20.09";

  # Who am I?
  home.username = "ambroisie";
}
