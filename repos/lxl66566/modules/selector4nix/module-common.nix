{
  lib,
  pkgs,
  packageDefault ? pkgs.selector4nix,
}:

let
  settingsFormat = pkgs.formats.toml { };
in
{
  mkConfigFile =
    cfg:
    let
      rawConfigFile = settingsFormat.generate "selector4nix.raw.toml" cfg.settings;
    in
    pkgs.runCommand "selector4nix.toml" { } ''
      echo 'Checking the configuration file `selector4nix.toml` via `selector4nix check`'
      ${cfg.package}/bin/selector4nix --config-file "${rawConfigFile}" check && cp ${rawConfigFile} $out
    '';

  serviceOptions = {
    enable = lib.mkOption {
      type = lib.types.bool;
      description = "Whether to enable selector4nix";
      default = false;
      example = true;
    };

    package = lib.mkOption {
      type = lib.types.package;
      description = "The selector4nix package to use";
      default = packageDefault;
    };

    logLevel = lib.mkOption {
      type = lib.types.enum [
        "error"
        "warn"
        "info"
        "debug"
        "trace"
      ];
      description = "The verbosity of the logging output";
      default = "info";
      example = "debug";
    };

    settings = lib.mkOption {
      type = lib.types.submodule {
        freeformType = settingsFormat.type;
        options.server = {
          ip = lib.mkOption {
            type = lib.types.str;
            description = "The IP address that selector4nix listens on";
            default = "127.0.0.1";
            example = "127.0.0.1";
          };

          port = lib.mkOption {
            type = lib.types.port;
            description = "The port that selector4nix listens on";
            default = 5496;
            example = 5496;
          };
        };
      };
      description = "The configuration that will be read by selector4nix";
      default = { };
      example = {
        server = {
          ip = "127.0.0.1";
        };
        substituters = [
          {
            url = "https://cache.nixos.org/";
          }
          {
            url = "https://mirrors.ustc.edu.cn/nix-channels/store/";
            priority = 45;
          }
          {
            url = "https://cache.garnix.io/";
            storage_url = "https://garnix-cache.com/";
          }
        ];
      };
    };

    credentialFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      description = "The credential file that will be read by selector4nix";
      default = null;
      example = "/path/to/your/credentials.toml";
    };

    enablePersistentCaching = lib.mkOption {
      type = lib.types.bool;
      description = "Whether to enable persistent caching";
      default = false;
      example = true;
    };

    configureSubstituter = lib.mkOption {
      type = lib.types.enum [
        "keep"
        "prepend"
        "overwrite"
      ];
      description = "Whether to configure the substituter list. by either prepending or rewriting";
      default = "keep";
      example = "overwrite";
    };
  };

  mkSubstituterConfig =
    cfg:
    lib.mkMerge [
      (lib.mkIf (cfg.enable && cfg.configureSubstituter == "prepend") {
        nix.settings.substituters = lib.mkBefore [
          "http://${cfg.settings.server.ip}:${toString cfg.settings.server.port}/"
        ];
      })

      (lib.mkIf (cfg.enable && cfg.configureSubstituter == "overwrite") {
        nix.settings.substituters = lib.mkForce [
          "http://${cfg.settings.server.ip}:${toString cfg.settings.server.port}/"
        ];
      })
    ];
}
