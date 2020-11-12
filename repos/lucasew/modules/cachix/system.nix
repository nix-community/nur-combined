{pkgs, ...}:
let
  pathIfExists = import <dotfiles/lib/pathListIfExist.nix>;
in
{
  imports = pathIfExists /etc/nixos/cachix.nix;
  environment.systemPackages = with pkgs; [
    cachix
  ];
}
