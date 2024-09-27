# A simple podcast fetcher
{ config, lib, ... }:
let
  cfg = config.my.services.podgrab;
in
{
  options.my.services.podgrab = with lib; {
    enable = mkEnableOption "Podgrab, a self-hosted podcast manager";

    passwordFile = mkOption {
      type = with types; nullOr str;
      default = null;
      example = "/run/secrets/password.env";
      description = ''
        The path to a file containing the PASSWORD environment variable
        definition for Podgrab's authentication.
      '';
    };

    dataDir = mkOption {
      type = with types; nullOr str;
      default = null;
      example = "/mnt/podgrab";
      description = ''
        Path to the directory to store the podcasts. Use default if null
      '';
    };

    port = mkOption {
      type = types.port;
      default = 8080;
      example = 4242;
      description = "The port on which Podgrab will listen for incoming HTTP traffic.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.podgrab = {
      enable = true;
      inherit (cfg) passwordFile port;

      group = "media";
      dataDirectory = lib.mkIf (cfg.dataDir != null) cfg.dataDir;
    };

    # Set-up media group
    users.groups.media = { };

    my.services.nginx.virtualHosts = {
      podgrab = {
        inherit (cfg) port;
      };
    };
  };
}
