{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.udisks;
in {
  options.services.udisks = {
    enable = mkEnableOption ''
      udsiks server
    '';
  };

  config = mkIf cfg.enable {
    services.udisks2.enable = true;
    environment = {
      systemPackages = with pkgs; [ ntfs3g ];
    };
    services.xserver.displayManager.sessionCommands = ''
      ${pkgs.udiskie}/bin/udiskie -s -f spacefm &
    '';
  };
}
