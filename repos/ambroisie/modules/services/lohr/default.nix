# A simple Gitea webhook to mirror all my repositories
{ config, lib, pkgs, ... }:
let
  cfg = config.my.services.lohr;
  settingsFormat = pkgs.formats.yaml { };

  lohrPkg = pkgs.ambroisie.lohr;
in
{
  options.my.services.lohr = with lib; {
    enable = mkEnableOption "Automatic gitea repositories mirroring";

    port = mkOption {
      type = types.port;
      default = 9192;
      example = 8080;
      description = "Internal port of the Lohr service";
    };

    setting = mkOption rec {
      type = settingsFormat.type;
      apply = recursiveUpdate default;
      default = {
        default_remotes = [
          "git@github.com:ambroisie"
          "git@git.sr.ht:~ambroisie"
        ];
      };
      description = "Global settings configuration file";
    };

    sharedSecretFile = mkOption {
      type = types.str;
      example = "/run/secrets/lohr.env";
      description = "Shared secret between lohr and Gitea hook";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.lohr = {
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        EnvironmentFile = [
          cfg.sharedSecretFile
        ];
        Environment = [
          "ROCKET_PORT=${toString cfg.port}"
          "ROCKET_LOG_LEVEL=normal"
          "LOHR_HOME=/var/lib/lohr/"
          "LOHR_CONFIG="
        ];
        ExecStart =
          let
            configFile = settingsFormat.generate "lohr-config.yaml" cfg.setting;
          in
          "${lohrPkg}/bin/lohr --config ${configFile}";
        StateDirectory = "lohr";
        WorkingDirectory = "/var/lib/lohr";
        User = "lohr";
        Group = "lohr";
      };
      path = with pkgs; [
        git
      ];
    };

    users.users.lohr = {
      isSystemUser = true;
      home = "/var/lib/lohr";
      createHome = true;
      group = "lohr";
    };
    users.groups.lohr = { };

    my.services.nginx.virtualHosts = [
      {
        subdomain = "lohr";
        inherit (cfg) port;
      }
    ];
  };
}
