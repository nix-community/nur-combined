{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.udisks;
in {
  options.services.udisks = {
    enable = mkEnableOption ''
      udisks server
    '';
  };

  config = mkIf cfg.enable {
    services.udisks2.enable = true;
    environment = {
      systemPackages = with pkgs; [ ntfs3g bashmount ];
    };
  };
}
