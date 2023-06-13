imports: { config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.server;
  ip4 = pkgs.nur.repos.dukzcry.lib.ip4;
in {
  inherit imports;

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
        systemPackages = with pkgs; [
          jellyfin-media-player
          transmission-remote-gtk
          moonlight-qt
          pkgs.nur.repos.dukzcry.cockpit-client
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
      services.tailscale.enable = true;
    })
  ];
}
