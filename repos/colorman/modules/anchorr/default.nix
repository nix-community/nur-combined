{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.anchorr;

  anchorrOpts = with lib;
    {name, ...}: {
      options = {
        enable = mkEnableOption "Anchorr instance";

        name = mkOption {
          type = types.str;
          default = name;
          description = ''
            Name is used as a suffix for the service name. By default it takes
            the value you used for `<instance>` in:
            {option}`services.anchorr.<instance>`
          '';
        };

        package = mkPackageOption pkgs.nur.repos.colorman "anchorr" {};

        settings = mkOption {
          type = with types; nullOr attrs;
          default = null;
          example = {
            JELLYFIN_BASE_URL = "http://localhost:8096";
          };
          description = ''
            Settings file written to
            {file}`/var/lib/anchorr-<instance>/config/config.json`. For
            available configuration options, see
            [Anchorr/lib/config.js](https://github.com/nairdahh/Anchorr/blob/0875b285dca22e5943fa13428886f84c3303baed/lib/config.js).
            This file should NOT be used to store secrets. Use
            {option}`services.anchorr.<instance>.settingsFile` instead. This
            option and `settingsFile` will be merged, with options from
            `settingsFile` taking precedense.
          '';
        };

        settingsFile = mkOption {
          type = with types; nullOr path;
          default = null;
          example = "/run/secrets/anchorr.json";
          description = ''
            Path to a JSON file containing settings that will be merged with
            the `settings` option. This is suitable for storing secrets, as
            they will not be exposed in the Nix store.
          '';
        };
      };
    };
in {
  options.services.anchorr = with lib;
    mkOption {
      default = {};
      type = with types; attrsOf (submodule anchorrOpts);
      description = ''
        Defines multiple Anchorr instances. If you don't require multiple
        instances of Anchorr, you can define just one.
      '';
      example = ''
        {
          main = {
            enable = true;
            settings = { ... };
            settingsFile = "/run/secrets/anchorr-main.json";
          };
          secondary = {
            enable = true;
            settings = { ... };
            settingsFile = "/run/secrets/anchorr-secondary.json";
          };
        }
      '';
    };

  config = let
    mkInstanceServiceConfig = instance: let
      stateDir = "anchorr-${instance.name}";
      statePath = "/var/lib/${stateDir}";

      jsonConfigFile = pkgs.writers.writeJSON "config.json" instance.settings;

      publicConfigSegment =
        lib.optionalString (instance.settings != null)
        ''
          const settings_json = "${jsonConfigFile}";
          Object.assign(
            loaded_settings,
            JSON.parse(fs.readFileSync(settings_json, "utf8"))
          );
        '';

      secretConfigSegment =
        lib.optionalString (instance.settingsFile != null)
        ''
          const path = require("node:path");
          const secret_settings_json = path.join(
            process.env.CREDENTIALS_DIRECTORY,
            "secretConfigFile"
          );
          Object.assign(
            loaded_settings,
            JSON.parse(fs.readFileSync(secret_settings_json, "utf8"))
          );
        '';

      generateJsonConfig = pkgs.writeScript "generate-config.js" ''
        #!${pkgs.nodejs}/bin/node

        "use strict";
        const fs = require("fs");
        let loaded_settings = {};

        ${publicConfigSegment}
        ${secretConfigSegment}

        fs.writeFileSync(
          "${statePath}/config/config.json",
          JSON.stringify(loaded_settings)
        );
      '';
    in {
      description = "Anchorr, ${instance.name} instance";
      wantedBy = ["multi-user.target"];
      after = ["network.target"];
      preStart =
        lib.optionalString (
          instance.settings != null || instance.settingsFile != null
        ) ''
          mkdir -p '${statePath}/config'
          ${generateJsonConfig}
        '';

      serviceConfig = {
        Type = "simple";
        ExecStart = "${instance.package}/bin/anchorr";
        Restart = "on-failure";
        StateDirectory = stateDir;
        WorkingDirectory = statePath;

        LoadCredential = lib.mkIf (instance.settingsFile != null) "secretConfigFile:${instance.settingsFile}";

        # Hardening
        NoNewPrivileges = true;
        PrivateTmp = true;
        PrivateDevices = true;
        DevicePolicy = "closed";
        DynamicUser = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        ProtectControlGroups = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        RestrictAddressFamilies = [
          "AF_UNIX"
          "AF_INET"
          "AF_INET6"
          "AF_NETLINK"
        ];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        LockPersonality = true;
        SystemCallFilter = [
          "~@cpu-emulation"
          "~@debug"
          "~@keyring"
          "~@memlock"
          "~@obsolete"
          "~@privileged"
          "~@setuid"
        ];
      };
    };
    instances = lib.attrValues cfg;
    mapInstances = f: lib.mkMerge (map f instances);
  in {
    systemd.services = mapInstances (instance:
      lib.mkIf instance.enable {
        "anchorr-${instance.name}" = mkInstanceServiceConfig instance;
      });
  };
}
