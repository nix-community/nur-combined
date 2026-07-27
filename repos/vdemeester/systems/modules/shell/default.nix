{ lib, ... }:
let
  inherit (lib) mkEnableOption;
in
{
  imports = [
    ./direnv.nix
    ./git.nix
    ./gnupg.nix
    ./tmux.nix
    ./zsh.nix
  ];
}
