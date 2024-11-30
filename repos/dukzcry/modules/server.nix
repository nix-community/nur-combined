{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.server;
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
        ];
      };
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
      environment.systemPackages = with pkgs; with pkgs.nur.repos.dukzcry; [
        moonlight-qt syncthing minicom
      ];
      services.yggdrasil = {
        enable = true;
        configFile = "/etc/yggdrasil.conf";
      };
      systemd.services.yggdrasil.wantedBy = mkForce [];
    })
  ];
}
