{ pkgs, ... }:

{
  imports = [
    ./base.nix
  ];
  profiles.dev.go.enable = true;
  profiles.emacs.texlive = false;
  home.packages = with pkgs; [ docker ];
}
