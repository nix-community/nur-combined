{ pkgs, ... }:

with import ../assets/machines.nix; {
  imports = [
    ./nixos-base.nix
  ];
  home.packages = with pkgs; [
    ripgrep
  ];
  profiles.gpg.enable = true;
  xdg.configFile."ape.conf".source = ../assets/ape.conf;
}
