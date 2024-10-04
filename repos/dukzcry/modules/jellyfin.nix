{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.programs.jellyfin;
in {
  options.programs.jellyfin = {
    enable = mkEnableOption "jellyfin server";
  };

  config = mkIf cfg.enable {
    services.jellyfin.enable = true;
    nixpkgs.config.packageOverrides = pkgs: {
      vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
    };
    hardware.opengl = {
      enable = mkDefault true;
      extraPackages = with pkgs; [
        intel-media-driver intel-vaapi-driver vaapiVdpau intel-compute-runtime intel-media-sdk
      ];
    };

    services.jellyseerr.enable = true;
    services.sonarr.enable = true;
    services.sonarr.group = config.services.transmission.group;
    services.radarr.enable = true;
    services.radarr.group = config.services.transmission.group;
    services.jackett.enable = true;
    # todo: replace with services.flaresolver option
    systemd.services.flaresolverr = {
      after = [ "network.target" ];
      serviceConfig = {
        User = config.services.jackett.user;
        Group = config.services.jackett.group;
        Restart = "always";
        RestartSec = 5;
        TimeoutStopSec = 30;
        ExecStart = "${pkgs.nur.repos.xddxdd.flaresolverr}/bin/flaresolverr";
      };
      wantedBy = [ "multi-user.target" ];
    };
  };
}
