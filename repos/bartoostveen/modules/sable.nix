{
  pkgs,
  lib,
  config,
  ...
}:

let
  inherit (lib)
    # keep-sorted start
    filterAttrs
    getExe
    mkDefault
    mkEnableOption
    mkIf
    mkOption
    mkPackageOption
    optional
    types
    # keep-sorted end
    ;

  inherit (types)
    # keep-sorted start
    attrs
    bool
    ints
    listOf
    nullOr
    path
    str
    submodule
    # keep-sorted end
    ;

  cfg = config.services.sable;

  configFormat = pkgs.formats.toml { };
in
{
  options.services.sable = {
    enable = mkEnableOption "Sable, an almost stable Matrix client";
    package = mkPackageOption pkgs "sable-next-server" { };
    frontendPackage = mkPackageOption pkgs "sable-next-server-frontend" { };
    configFile = mkOption {
      description = "File that contains the server config, overrides services.sable.settings!";
      type = path;
      default = configFormat.generate "sable.toml" (filterAttrs (_: value: value != null) cfg.settings);
      defaultText = "<<generated TOML from services.sable.settings>>";
    };
    enableWrapper = mkOption {
      description = "Whether to add a wrapped sable-server to the path that refers to the server's config file";
      type = bool;
      default = true;
      example = false;
    };
    environmentFile = mkOption {
      description = ''
        File that contains values for the Sable config. This file may be used for secrets.

        ::: {.note}
        See the [Sable documentation](https://docs.sable.moe/installation/server-mode/#configuration) on environment variables.
        :::
      '';
      type = nullOr path;
      default = null;
      example = "/run/secrets/sable.env";
    };
    settings = mkOption {
      description = "Sable server config";
      type = submodule {
        freeformType = attrs;
        options = {
          listen_addr = mkOption {
            description = "Address and port to listen on";
            type = str;
            default = "127.0.0.1:18008";
          };
          public_url = mkOption {
            description = "Origin the browser opens, without a path. HTTP is only allowed for loopback";
            type = str;
            default = "http://127.0.0.1:18008";
            example = "https://sable.example.com";
          };
          client_ip_source = mkOption {
            description = ''
              Determines where rate limiting reads the client address from.

              ::: {.note}
              See the [axum-client-ip crate's documentation](https://docs.rs/axum-client-ip/latest/axum_client_ip/enum.ClientIpSource.html).
              :::
            '';
            type = str;
            default = "ConnectInfo";
            example = "CfConnectingIp";
          };
          data_dir = mkOption {
            description = ''
              Where Sable stores persistent data

              ::: {.warning}
              When using anything other than the default, make sure to grant the service write access to this directory yourself.
              :::
            '';
            type = path;
            default = "/var/lib/sable/data";
            example = "/path/to/sable/data";
          };
          allowed_private_cidrs = mkOption {
            description = "Private addresses or ranges every user may reach";
            type = listOf str;
            default = [ ];
            example = [ "example.com" ];
          };
          max_active_users = mkOption {
            description = "Most users loaded at once, including the first account";
            type = ints.positive;
            default = 128;
            example = 1;
          };
          username = mkOption {
            description = "Username of the first account";
            type = str;
            default = "sable";
            example = "johndoe";
          };
          password_hash = mkOption {
            description = ''
              Argon2id hash for the first account, generate using `sable-server hash-password`

              ::: {.warning}
              Consider putting this in {option}`services.sable.environmentFile` instead.
              :::
            '';
            type = nullOr str;
            default = null;
          };
          oidc_issuer = mkOption {
            description = "OpenID Connect issuer URL";
            type = nullOr str;
            default = null;
          };
          oidc_client_id = mkOption {
            description = "OpenID Connect client ID";
            type = nullOr str;
            default = null;
          };
          oidc_client_secret = mkOption {
            description = ''
              OpenID Connect client secret

              ::: {.important}
              You should never set this option in a production setup, as this copies the OIDC client secret into the world-readable Nix store.
              Use an entry in {option}`services.sable.environmentFile` instead.
              :::
            '';
            type = nullOr str;
            default = null;
          };
          oidc_auto_provision = mkOption {
            description = "Whether to create an account on a person's first OIDC login";
            type = bool;
            default = false;
            example = true;
          };
          frontend_dir = mkOption {
            description = "Path to the server-mode frontend dist. Overriding this means that {option}`services.sable.frontendPackage` has no effect.";
            type = path;
            example = "/srv/sable";
          };
        };
      };
      default = { };
    };
  };
  config = mkIf cfg.enable {
    warnings = optional (cfg.settings.oidc_client_secret != null) ''
      services.sable.settings.oidc_client_secret is set.

      This copies the OIDC client secret into the world-readable Nix store.
      You should never do this in a production setup! It is recommended to use `services.sable.environmentFile` instead.
    '';

    services.sable.settings = {
      frontend_dir = mkDefault cfg.frontendPackage;
    };

    systemd.services.sable = {
      description = "Sable, an almost stable Matrix client";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      preStart = ''
        mkdir -p "$STATE_DIRECTORY/data"
      '';
      serviceConfig = {
        Type = "simple";
        ExecStart = ''
          ${getExe cfg.package} --config ${cfg.configFile}
        '';
        DynamicUser = true;
        EnvironmentFile = cfg.environmentFile;
        StateDirectory = "sable";
        WorkingDirectory = "%S/sable";
        Restart = "on-failure";
        AmbientCapabilities = "";
        CapabilityBoundingSet = "";
        LockPersonality = true;
        MountAPIVFS = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateMounts = true;
        PrivateTmp = true;
        ProtectClock = true;
        ProtectControlGroups = "strict";
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        ProtectSystem = "strict";
        RemoveIPC = true;
        RestrictAddressFamilies = "AF_INET AF_INET6 AF_UNIX";
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallArchitectures = "native";
        UMask = 27;
      };
    };

    environment.systemPackages = mkIf cfg.enableWrapper [
      (pkgs.writeShellApplication {
        name = "sable";
        runtimeInputs = [ cfg.package ];
        text = ''
          sable-server --config ${cfg.configFile} "$@"
        '';
      })
    ];
  };
}
