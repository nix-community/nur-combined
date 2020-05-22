{ config, lib, ... }:

with lib; {
  options = {
    machine = {
      home-manager = mkEnableOption "It is a home-manager configuration";
      nixos = mkEnableOption "It is a nixos configuration";
      base = {
        fedora = mkEnableOption "The base OS is Fedora";
        debian = mkEnableOption "The base OS is Debian";
        ubuntu = mkEnableOption "The base OS is Ubuntu";
      };
    };
  };
}
