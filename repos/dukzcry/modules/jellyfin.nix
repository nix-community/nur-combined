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
    hardware.graphics = {
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
    services.prowlarr.enable = true;
  };
}
