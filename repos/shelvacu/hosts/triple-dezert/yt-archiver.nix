{ config, ... }:
{
  systemd.tmpfiles.settings.vacu-container-yt-archive = {
    "/var/container-applets/yt-archive".d = { };
    "/nix/var/nix/gcroots/container-applets-yt-archive"."L+".argument =
      "/var/container-applets/yt-archive";
  };
  containers.yt-archive = {
    privateNetwork = true;
    hostAddress = "192.168.100.24";
    localAddress = "192.168.100.25";

    autoStart = false;
    ephemeral = false;

    bindMounts."/a" = {
      hostPath = "/trip/ffuts/archive";
      isReadOnly = false;
    };

    bindMounts."/applets" = {
      hostPath = "/var/container-applets/yt-archive";
      isReadOnly = true;
    };

    config =
      { pkgs, lib, ... }:
      {
        system.stateVersion = "23.05";

        networking.firewall.enable = false;
        networking.useHostResolvConf = lib.mkForce false;
        services.resolved.enable = true;

        environment.systemPackages = [ pkgs.yt-dlp ];
      };
  };
}
