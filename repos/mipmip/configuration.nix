{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./shared-configuration.nix
      ./hosts/ojs-nixos.nix
    ];
}
