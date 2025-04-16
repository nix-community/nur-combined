# Automatic cross-seeding for video media
{ config, lib, ... }:
let
  cfg = config.my.services.servarr.cross-seed;
in
{
  options.my.services.servarr.cross-seed = with lib; {
    enable = mkEnableOption "cross-seed daemon" // {
      default = config.my.services.servarr.enableAll;
    };

    port = mkOption {
      type = types.port;
      default = 2468;
      example = 8080;
      description = "Internal port for daemon";
    };

    linkDirectory = mkOption {
      type = types.str;
      default = "/data/downloads/complete/links";
      example = "/var/lib/cross-seed/links";
      description = "Link directory";
    };

    secretSettingsFile = mkOption {
      type = types.str;
      example = "/run/secrets/cross-seed-secrets.json";
      description = ''
        File containing secret settings.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services.cross-seed = {
      enable = true;
      group = "media";

      # Rely on recommended defaults for tracker snatches etc...
      useGenConfigDefaults = true;

      settings = {
        inherit (cfg) port;
        host = "127.0.0.1";

        # Inject torrents to client directly
        action = "inject";
        # Query the client for torrents to match
        useClientTorrents = true;
        # Use hardlinks
        linkType = "hardlink";
        # Use configured link directory
        linkDirs = [ cfg.linkDirectory ];
        # Match as many torrents as possible
        matchMode = "partial";
        # Cross-seed full season if at least 50% of episodes are already downloaded
        seasonFromEpisodes = 0.5;
      };

      settingsFile = cfg.secretSettingsFile;
    };

    systemd.services.cross-seed = {
      serviceConfig = {
        # Loose umask to make cross-seed links readable by `media`
        UMask = "0002";
      };
    };

    # Set-up media group
    users.groups.media = { };

    my.services.nginx.virtualHosts = {
      cross-seed = {
        inherit (cfg) port;
      };
    };

    services.fail2ban.jails = {
      cross-seed = ''
        enabled = true
        filter = cross-seed
        action = iptables-allports
      '';
    };

    environment.etc = {
      "fail2ban/filter.d/cross-seed.conf".text = ''
        [Definition]
        failregex = ^.*Unauthorized API access attempt to .* from <HOST>$
        journalmatch = _SYSTEMD_UNIT=cross-seed.service
      '';
    };
  };
}
