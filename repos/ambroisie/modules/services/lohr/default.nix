# A simple Gitea webhook to mirror all my repositories
{ config, lib, pkgs, ... }:
let
  cfg = config.my.services.lohr;
  settingsFormat = pkgs.formats.yaml { };

  lohrPkg = pkgs.ambroisie.lohr;

  lohrStateDirectory = "lohr";
  lohrHome = "/var/lib/lohr/";
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

    sshKeyFile = mkOption {
      type = with types; nullOr str;
      default = null;
      example = "/run/secrets/lohr/ssh-key";
      description = ''
        The ssh key that should be used by lohr to mirror repositories
      '';
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
          "LOHR_HOME=${lohrHome}"
          "LOHR_CONFIG="
        ];
        ExecStartPre = lib.mkIf (cfg.sshKeyFile != null) ''+${
          pkgs.writeScript "copy-ssh-key" ''
            #!${pkgs.bash}/bin/bash
            # Ensure the key is not there
            mkdir -p '${lohrHome}/.ssh'
            rm -f '${lohrHome}/.ssh/id_ed25519'

            # Move the key into place
            cp ${cfg.sshKeyFile} '${lohrHome}/.ssh/id_ed25519'

            # Fix permissions
            chown -R lohr:lohr '${lohrHome}/.ssh'
            chmod -R 0700 '${lohrHome}/.ssh'
          ''
        }'';
        ExecStart =
          let
            configFile = settingsFormat.generate "lohr-config.yaml" cfg.setting;
          in
          "${lohrPkg}/bin/lohr --config ${configFile}";
        StateDirectory = lohrStateDirectory;
        WorkingDirectory = lohrHome;
        User = "lohr";
        Group = "lohr";
      };
      path = with pkgs; [
        git
      ];
    };

    users.users.lohr = {
      isSystemUser = true;
      home = lohrHome;
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
