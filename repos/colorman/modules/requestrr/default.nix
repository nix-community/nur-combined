{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.services.requestrr;

  requestrrOpts = with lib;
    {name, ...}: {
      options = {
        enable = mkEnableOption "Requestrr instance";

        name = mkOption {
          type = types.str;
          default = name;
          description = ''
            Name is used as a suffix for the service name. By default it takes
            the value you use for `<instance>` in:
            {option}`services.requestrr.instances.<instances>`
          '';
        };

        package = mkPackageOption pkgs.nur.repos.colorman "requestrr" {};

        settings = mkOption {
          type = types.attrs;
          default = {};
          example = {
            Port = 6666;
            BaseUrl = "https://requestrr.example.com";
            DisableAuthentication = true;
          };
          description = ''
            Settings file written to
            {file}`/var/lib/requestrr-<instance>/settings.json`. It is
            recommended to configure Requestrr through its Web UI initially,
            then copy the resulting settings to this option by running it
            through `builtins.fromJSON`. Settings this option will *not* make
            the file read-only, but it *WILL* erase any existing settings not
            defined here!
          '';
        };
      };
    };
in {
  options.services.requestrr.instances = with lib;
    mkOption {
      default = {};
      type = types.attrsOf (types.submodule requestrrOpts);
      description = ''
        Defines multiple Requestrr intances. If you don't require multiple
        instances of Requestrr, you can define just the one.
      '';
      example = ''
        {
        	main = {
        		enable = true;
        		settings = { ... };
        	};
        	withSops = {
        		enable = true;
        		settings = { ... };
        	};
        }
      '';
    };

  config = let
    mkInstanceServiceConfig = instance: let
      stateDir = "requestrr-${instance.name}";
    in {
      description = "Requestrr, ${instance.name} instance";
      wantedBy = ["multi-user.target"];
      after = ["network.target"];
      serviceConfig = {
        Type = "simple";
        ExecStart = ''
          ${instance.package}/bin/Requestrr.WebApi \
          	-c /var/lib/${stateDir}
        '';
        Restart = "on-failure";
        StateDirectory = stateDir;

        # Hardening
        NoNewPrivileges = true;
        PrivateTmp = true;
        PrivateDevies = true;
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
        RestrictNameSpaces = true;
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
    instances = lib.attrValues cfg.instances;
    mapInstances = f: lib.mkMerge (map f instances);
  in {
    systemd.services = mapInstances (instance:
      lib.mkIf instance.enable {
        "requestrr-${instance.name}" = mkInstanceServiceConfig instance;
      });

    system.activationScripts = mapInstances (
      instance:
        lib.mkIf (
          instance.enable
          && (builtins.length (builtins.attrNames instance.settings) != 0)
        ) {
          "requestrr-${instance.name}-write-settings" = let
            statePath = "/var/lib/requestrr-${instance.name}";
          in
            lib.stringAfter
            ["var"] ''
              mkdir -p ${statePath}
              cp ${pkgs.writeText "requestrr-${instance.name}-settings"
                (builtins.toJSON instance.settings)} ${statePath}/settings.json
              chmod u+w ${statePath}/settings.json
            '';
        }
    );
  };
}
