{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.server;
  ip4 = pkgs.nur.repos.dukzcry.lib.ip4;
in {
  options.services.server = {
    enable = mkEnableOption ''
      Support for my home server
    '';
    remote = mkEnableOption ''
      Support for remote use
    '';
  };

  config = mkMerge [
    (mkIf cfg.enable {
      system.fsPackages = [ pkgs.nfs-utils ];
      systemd.mounts = [{
        type = "nfs";
        what = "robocat:/data";
        where = "/data";
      }];
      systemd.automounts = [{
        wantedBy = [ "multi-user.target" ];
        automountConfig = {
          TimeoutIdleSec = "600";
        };
        where = "/data";
      }];
      environment = {
        systemPackages = with pkgs; with pkgs.nur.repos.dukzcry; [
          jellyfin-media-player
          transmission-remote-gtk
          cockpit-client
        ];
      };
      services.tor.enable = lib.mkForce false;
      virtualisation.spiceUSBRedirection.enable = true;
      systemd.sockets.cups.wantedBy = mkForce [];
      systemd.services.cups.wantedBy = mkForce [];
      services.printing = {
        enable = true;
        clientConf = ''
          ServerName robocat
        '';
      };
    })
    (mkIf cfg.remote {
      virtualisation.libvirtd.enable = lib.mkForce false;
      environment.systemPackages = with pkgs; with pkgs.nur.repos.dukzcry; [
        awl-tray
        moonlight-qt
        steamlink
      ];
    })
  ];
}
