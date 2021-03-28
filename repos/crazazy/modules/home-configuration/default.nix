{ lib, ... }:
{
  imports = [
    ./keybase.nix
    ./doom-emacs.nix
  ];
  options.privateConfig.enable = lib.mkEnableOption "Enable the private home-manager configuration";
}
