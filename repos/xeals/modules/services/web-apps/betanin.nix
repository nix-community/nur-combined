{ config, lib, pkgs, ... }:

let
  inherit (lib) mkIf mkOption optionalAttrs optionalString types;
  cfg = config.services.betanin;

  defaultUser = "betanin";
  defaultGroup = "betanin";
  defaultSettings = {
    notifications = {
      services = { };
      strings = {
        title = "[betanin] torrent `$name` $status";
        body = "@ $time. view/use the console at http://127.0.0.1:${toString cfg.port}/$console_path";
      };
    };
  };

  finalSettings =
    let
      base = lib.filterAttrsRecursive (n: _: !(lib.hasSuffix "_file" n)) cfg.settings;
      clean = {
        frontend.password =
          if cfg.settings.frontend.password_file != null
          then "@password@"
          else cfg.settings.frontend.password;
        clients.api_key =
          if cfg.settings.clients.api_key_file != null
          then "@api_key@"
          else cfg.settings.clients.api_key;
      };
    in
    lib.foldl' lib.recursiveUpdate defaultSettings [ base clean ];

  settingsFormat = pkgs.formats.toml { };
  settingsFile = settingsFormat.generate "betanin.toml" finalSettings;

  beetsFormat = pkgs.formats.yaml { };
  beetsFile =
    if (cfg.beetsFile != null)
    then cfg.beetsFile
    else if (cfg.beetsConfig != { })
    then beetsFormat.generate "betanin-beets.yaml" cfg.beetsConfig
    else null;
in
{
  options = {
    services.betanin = {
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
        default = defaultUser;
      };

      group = mkOption {
        description = "Group that the betanin program should run under.";
        type = types.str;
        default = defaultGroup;
      };

      dataDir = mkOption {
        description = "Directory to store application data.";
        type = types.str;
        default = "/var/lib/betanin";
      };

      settings = mkOption {
        type = types.submodule {
          freeformType = settingsFormat.type;

          options.frontend.username = mkOption {
            type = types.str;
            default = "";
            description = "Username used to log into the frontend. Must be set.";
          };

          options.frontend.password = mkOption {
            type = types.str;
            default = "";
            description = ''
              Password used to log into the frontend. Either password or
              password_file must be set.
            '';
          };

          options.frontend.password_file = mkOption {
            type = with types; nullOr (either str path);
            default = null;
            description = ''
              File containing the password used to log into the frontend. The
              file must be readable by the betanin user/group.

              Using a password file keeps the password out of the Nix store, but
              the password is still stored in plain text in the service data
              directory.
            '';
          };

          options.clients.api_key = mkOption {
            type = types.nullOr types.str;
            default = "";
            description = ''
              API key used to access Betanin (e.g., from other services).
            '';
          };

          options.clients.api_key_file = mkOption {
            type = with types; nullOr (either str path);
            default = null;
            description = ''
              File containing the API key used to access Betanin (e.g., from
              other services). The file must be readable by the betanin
              user/group.

              Using a API key file keeps the API key out of the Nix store, but
              the API key is still stored in plain text in the service data
              directory.
            '';
          };
        };
        default = defaultSettings;
        example = lib.literalExpression ''
          {
            frontend = {
              username = "foo";
              password_file = "/run/secrets/betaninPasswordFile";
            };
            clients = {
              api_key_file = "/run/secrets/betaninApiKeyFile";
            };
            server = {
              num_parallel_jobs = 1;
            };
          }
        '';
        description = "Configuration for betanin.";
      };

      beetsConfig = mkOption {
        description = "beets configuration.";
        type = beetsFormat.type;
        default = { };
      };

      beetsFile = mkOption {
        description = "beets configuration file.";
        type = with types; nullOr (either str path);
        default = null;
      };
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.settings.frontend.username != "";
        message = "services.betanin.settings.frontend.username is required";
      }
      {
        assertion = (cfg.settings.frontend.password == "") != (cfg.settings.frontend.password_file == null);
        message = "services.betanin.settings.frontend.password or services.betanin.settings.frontend.password_file is required";
      }
      {
        assertion = (cfg.settings.clients.api_key == "") != (cfg.settings.clients.api_key_file == null);
        message = "services.betanin.settings.clients.api_key or services.betanin.settings.clients.api_key_file is required";
      }
    ];

    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.port ];
    };

    systemd.services.betanin =
      let
        replaceSecret = secretFile: placeholder: targetFile:
          optionalString (secretFile != null) ''
            ${pkgs.replace-secret}/bin/replace-secret ${placeholder} ${secretFile} ${targetFile}
          '';
        replaceConfigSecret = secretFile: placeholder:
          replaceSecret secretFile placeholder "${cfg.dataDir}/.config/betanin/config.toml";
      in
      {
        description = "Betanin service";
        wantedBy = [ "multi-user.target" ];
        after = [ "networking.target" ];
        environment = {
          HOME = cfg.dataDir;
        };
        path = [ pkgs.replace-secret ];

        script = ''
          mkdir -p ${cfg.dataDir}/.config/betanin \
            ${cfg.dataDir}/.config/beets \
            ${cfg.dataDir}/.local/share/betanin
          cat ${settingsFile} > ${cfg.dataDir}/.config/betanin/config.toml

          ${optionalString (beetsFile != null) ''
            ln -sf ${beetsFile} ${cfg.dataDir}/.config/betanin/config.toml
          ''}
          ${replaceConfigSecret cfg.settings.frontend.password_file "@password@"}
          ${replaceConfigSecret cfg.settings.clients.api_key_file "@api_key@"}

          ${cfg.package}/bin/betanin --port ${toString cfg.port}
        '';

        serviceConfig = lib.mkMerge [
          {
            User = cfg.user;
            Group = cfg.group;
            PrivateTmp = true;
            Restart = "always";
            WorkingDirectory = cfg.dataDir;
          }
          (mkIf (cfg.dataDir == "/var/lib/betanin") {
            StateDirectory = "betanin";
          })
        ];
      };

    users.users = optionalAttrs (cfg.user == defaultUser) {
      ${cfg.user} = {
        isSystemUser = true;
        group = cfg.group;
      };
    };

    users.groups = optionalAttrs (cfg.group == defaultGroup) {
      ${cfg.group} = { };
    };
  };
}
