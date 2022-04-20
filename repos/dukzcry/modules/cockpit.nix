{ config, lib, pkgs, ... }:

with lib;
let
  cpkgs = pkgs.nur.repos.dukzcry;
  cfg = config.services.cockpit;
in {
  options.services.cockpit = {
    enable = mkEnableOption ''
      Cockpit web-based graphical interface for servers
    '';
    port = mkOption {
      type = types.port;
      default = 9090;
    };
  };

  config = mkIf cfg.enable {
    systemd.packages = with cpkgs; [ (cockpit.override { packages = with pkgs; [ virtmanager ]; }) ];
    systemd.sockets.cockpit.wantedBy = [ "sockets.target" ];

    system.activationScripts = {
      cockpit = ''
        mkdir -p /etc/cockpit/ws-certs.d
        chmod 755 /etc/cockpit/ws-certs.d
      '';
    };

    security.pam.services.cockpit = {};

    environment.systemPackages = with cpkgs; [ cockpit cockpit-machines libvirt-dbus ];
    environment.pathsToLink = [ "/share/cockpit" ];

    systemd.sockets.cockpit.listenStreams = [ "" "${toString cfg.port}" ];
  };
}
