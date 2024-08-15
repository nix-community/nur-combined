{ config, lib, pkgs, ... }:

let
  inherit (builtins) hashString;
  inherit (lib) mkIf mkOption optionalAttrs types;

  cfg = config.services.betanin;

  settingsFormat = pkgs.formats.toml { };
  beetsFormat = pkgs.formats.yaml { };
in
{
  options.services.betanin = {
    enable = lib.mkEnableOption "betanin";

    package = mkOption {
      description = "Package containing betanin program.";
      type = types.package;
      default = pkgs.betanin or (import ../../.. { inherit pkgs; }).betanin;
    };

    openFirewall = mkOption {
      description = "Open ports in the firewall for the server.";
      type = types.bool;
      default = false;
    };

    port = mkOption {
      description = "Port to access betanin on.";
      type = types.port;
      default = 9393;
    };

    user = mkOption {
      description = "User that the betanin program should run under.";
      type = types.str;
      default = "betanin";
    };

    group = mkOption {
      description = "Group that the betanin program should run under.";
      type = types.str;
      default = "betanin";
    };

    dataDir = mkOption {
      description = "Directory to store application data.";
      type = types.str;
      default = "/var/lib/betanin";
    };

    settings = mkOption {
      type = settingsFormat.type;
      default = { };
      example = lib.literalExpression ''
        {
          frontend = {
            username = "foo";
            password = { _secret = "/run/secrets/betaninPasswordFile"; };
          };
          clients = {
            api_key = { _secret = "/run/secrets/betaninApiKeyFile"; };
          };
          server = {
            num_parallel_jobs = 1;
          };
        }
      '';
      description = ''
        Configuration for betanin.

        Options containing secret data should be set to an attribute set
        containing the attribute `_secret` - a string pointing to a file
        containing the value the option should be set to.
      '';
    };

    beets.settings = mkOption {
      type = beetsFormat.type;
      default = { };
      description = "Configuration for beets used by betanin.";
    };
  };

  config = mkIf cfg.enable {
    services.betanin.settings = {
      notifications = {
        # Required to exist.
        services = { };
        strings = {
          title = lib.mkDefault "[betanin] torrent `$name` $status";
          body = lib.mkDefault "@ $time. view/use the console at http://127.0.0.1:${toString cfg.port}/$console_path";
        };
      };
    };

    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.port ];
    };

    systemd.services.betanin =
      let
        isSecret = v: lib.isAttrs v && v ? _secret && lib.isString v._secret;
        sanitisedConfig = lib.mapAttrsRecursiveCond
          (as: !isSecret as)
          (_: v: if isSecret v then hashString "sha256" v._secret else v)
          cfg.settings;
        settingsFile = settingsFormat.generate "betanin.toml" sanitisedConfig;

        secretPaths = lib.catAttrs "_secret" (lib.collect isSecret cfg.settings);
        mkSecretReplacement = file: ''
          replace-secret ${hashString "sha256" file} ${file} "${cfg.dataDir}/.config/betanin/config.toml"
        '';
        secretReplacements = lib.concatMapStrings mkSecretReplacement secretPaths;

        beetsFile = beetsFormat.generate "betanin-beets.yaml" cfg.beets.settings;
      in
      {
        description = "Betanin service";
        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" ];
        path = [ pkgs.replace-secret ];

        environment = {
          HOME = cfg.dataDir;
        };

        script = ''
          ln -sf ${beetsFile} ${cfg.dataDir}/.config/beets/config.yaml
          cat ${settingsFile} > ${cfg.dataDir}/.config/betanin/config.toml
          ${secretReplacements}

          ${cfg.package}/bin/betanin --port ${toString cfg.port}
        '';

        serviceConfig = {
          User = cfg.user;
          Group = cfg.group;
          PrivateTmp = true;
          Restart = "always";
          WorkingDirectory = cfg.dataDir;
          StateDirectory = mkIf (cfg.dataDir == "/var/lib/betanin") "betanin";
        };
      };

    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir}                            0710 ${cfg.user} ${cfg.group} - -"
      "d ${cfg.dataDir}/.config                    0750 ${cfg.user} ${cfg.group} - -"
      "d ${cfg.dataDir}/.config/betanin            0750 ${cfg.user} ${cfg.group} - -"
      "d ${cfg.dataDir}/.config/beets              0750 ${cfg.user} ${cfg.group} - -"
      "d ${cfg.dataDir}/.local                     0750 ${cfg.user} ${cfg.group} - -"
      "d ${cfg.dataDir}/.local/share               0750 ${cfg.user} ${cfg.group} - -"
      "d ${cfg.dataDir}/.local/share/betanin       0750 ${cfg.user} ${cfg.group} - -"
    ];

    users.users = optionalAttrs (cfg.user == "betanin") {
      ${cfg.user} = {
        isSystemUser = true;
        group = cfg.group;
      };
    };

    users.groups = optionalAttrs (cfg.group == "betanin") {
      ${cfg.group} = { };
    };
  };
}
