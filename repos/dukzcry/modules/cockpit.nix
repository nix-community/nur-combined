{ config, lib, pkgs, ... }:

with lib;
let
  cockpit = pkgs.nur.repos.dukzcry.cockpit;
  cfg = config.services.cockpit;
in {
  options.services.cockpit = {
    enable = mkEnableOption ''
      Cockpit web-based graphical interface for servers
    '';
  };

  config = mkIf cfg.enable {
    systemd.packages = with pkgs; [ cockpit ];

    system.activationScripts = {
      cockpit = ''
        mkdir -p /etc/cockpit/ws-certs.d
        chmod 755 /etc/cockpit/ws-certs.d
      '';
    };

    security.pam.services.cockpit.allowNullPassword = true;

    environment.systemPackages = [ cockpit ];
    environment.pathsToLink = [ "/share/cockpit" ];
  };
}
