{ lib, pkgs }:
let
  jsonFormat = pkgs.formats.json { };
  absolutePath = lib.types.strMatching "/.*";
in
{
  commonOptions = {
    enable = lib.mkEnableOption "Magpie local AI gateway service";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.callPackage ../pkgs/magpie { };
      defaultText = lib.literalExpression "pkgs.callPackage ../pkgs/magpie { }";
      description = "Magpie package to run.";
    };

    listenAddress = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      example = "0.0.0.0";
      description = "Listen address for the Magpie gateway. Use brackets for IPv6.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 3425;
      description = "TCP port for the Magpie gateway.";
    };

    web = {
      enable = lib.mkEnableOption "serving the Magpie Web UI from the same process";

      keyFile = lib.mkOption {
        type = lib.types.nullOr absolutePath;
        default = null;
        example = "/run/secrets/magpie-web-key";
        description = ''
          File containing the raw Web UI sign-in key, read at service startup.
          On NixOS, systemd loads the file as a service credential, so it may be
          root-owned. On Darwin, it must be readable by the service user.
          Must contain at least 16 characters from letters, digits, hyphens,
          periods, underscores and tildes.
          Keep this file outside the Nix store. Overrides MAGPIE_WEB_KEY from
          environmentFile when set.
        '';
      };

      listenAddress = lib.mkOption {
        type = lib.types.str;
        default = "127.0.0.1";
        example = "0.0.0.0";
        description = "Listen address for the Magpie Web UI.";
      };

      port = lib.mkOption {
        type = lib.types.port;
        default = 3430;
        description = "TCP port for the Magpie Web UI.";
      };
    };

    tls = {
      certFile = lib.mkOption {
        type = lib.types.nullOr absolutePath;
        default = null;
        example = "/etc/letsencrypt/live/relay.example.com/fullchain.pem";
        description = "PEM certificate chain file for HTTPS.";
      };

      keyFile = lib.mkOption {
        type = lib.types.nullOr absolutePath;
        default = null;
        example = "/etc/letsencrypt/live/relay.example.com/privkey.pem";
        description = "PEM private key file for HTTPS. Keep this file outside the Nix store.";
      };
    };

    extraArgs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Additional command-line arguments passed to Magpie.";
    };

    settings = lib.mkOption {
      inherit (jsonFormat) type;
      default = { };
      example = {
        chinaMirror = true;
        redact = true;
        noAutoUpdate = true;
      };
      description = ''
        Declarative Magpie settings synchronized into settings.json on service
        start. Declared keys are enforced and previously declared keys removed
        from Nix are pruned automatically, while unmanaged keys remain writable
        by Magpie at runtime. Do not put secrets here; use settingsFile instead.
      '';
    };

    settingsFile = lib.mkOption {
      type = lib.types.nullOr absolutePath;
      default = null;
      example = "/run/secrets/magpie-settings.json";
      description = ''
        Runtime JSON object of secret or additional settings.json keys, such as
        githubToken or proxy credentials. Must be readable by the service user
        and kept outside the Nix store. Keys must not duplicate settings.
      '';
    };

    environment = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      example = {
        MAGPIE_PUBLIC_URL = "https://magpie.example.com";
        MAGPIE_ALLOW_IPS = "10.0.0.0/8,192.168.0.0/16";
      };
      description = ''
        Additional upstream environment variables. Do not put secrets here;
        use environmentFile instead.
      '';
    };

    environmentFile = lib.mkOption {
      type = lib.types.nullOr absolutePath;
      default = null;
      example = "/run/secrets/magpie.env";
      description = ''
        Runtime environment file containing secrets such as MAGPIE_WEB_KEY
        or OTLP headers. Keep this file outside the Nix store.
      '';
    };
  };

  helpers =
    cfg:
    let
      declaredSettings = lib.filterAttrs (_: value: value != null) (
        if builtins.isAttrs cfg.settings then cfg.settings else { }
      );
      settingsJson = pkgs.writeText "magpie-settings.json" (builtins.toJSON declaredSettings);
      configureCmd =
        configDirArg:
        "${pkgs.python3}/bin/python3 ${./magpie-configure.py} ${settingsJson}"
        + lib.optionalString (
          cfg.settingsFile != null
        ) " --settings-file ${lib.escapeShellArg cfg.settingsFile}"
        + lib.optionalString (configDirArg != null) " --config-dir ${lib.escapeShellArg configDirArg}";
      serveArgs = [
        "serve"
      ]
      ++ lib.optional cfg.web.enable "--web=${cfg.web.listenAddress}:${toString cfg.web.port}"
      ++ cfg.extraArgs;
      baseEnvironment = {
        MAGPIE_ADDR = "${cfg.listenAddress}:${toString cfg.port}";
        DO_NOT_TRACK = lib.mkDefault "1";
        MAGPIE_NO_STATS = lib.mkDefault "1";
      }
      // lib.optionalAttrs (cfg.tls.certFile != null) {
        MAGPIE_TLS_CERT = cfg.tls.certFile;
      }
      // lib.optionalAttrs (cfg.tls.keyFile != null) {
        MAGPIE_TLS_KEY = cfg.tls.keyFile;
      };
      assertions = [
        {
          assertion = builtins.isAttrs cfg.settings;
          message = "services.magpie.settings must be an attribute set.";
        }
        {
          assertion = (cfg.tls.certFile == null) == (cfg.tls.keyFile == null);
          message = "services.magpie.tls.certFile and services.magpie.tls.keyFile must be set together.";
        }
      ];
    in
    {
      inherit
        assertions
        baseEnvironment
        configureCmd
        declaredSettings
        serveArgs
        settingsJson
        ;
    };
}
