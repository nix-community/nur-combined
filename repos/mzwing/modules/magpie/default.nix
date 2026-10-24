{
  config,
  lib,
  pkgs,
  serviceLib,
  ...
}: let
  cfg = config.services.magpie;
  jsonFormat = pkgs.formats.json {};
  mergeConfig = (import ../../internal/config-merge {inherit pkgs;}).mkMergeConfig {
    name = "magpie-merge-config";
    format = "json";
  };

  serveArgs = ["serve"] ++ lib.optional cfg.web.enable "--web=${cfg.web.host}:${toString cfg.web.port}";

  startScript = executable:
    pkgs.writeShellApplication {
      name = "magpie-start";
      runtimeInputs = [mergeConfig];
      text = ''
        # Where magpie itself keeps its state.
        config_dir="''${XDG_CONFIG_HOME:-$HOME/.config}/magpie"

        mkdir -p -- "$config_dir"
        magpie-merge-config \
          "$config_dir/settings.json" \
          ${jsonFormat.generate "magpie-settings.json" cfg.settings} \
          "$config_dir/.magpie-nix-managed.json" \
          "$config_dir/settings.json.stateful"

        exec ${lib.escapeShellArg executable} ${lib.escapeShellArgs serveArgs}
      '';
    };

  options = {
    enable = lib.mkEnableOption "the magpie gateway";

    host = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "Address the gateway listens on. It is passed as `MAGPIE_ADDR`, so turning on sharing in magpie never widens it.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 3425;
      description = "Port the gateway listens on.";
    };

    web = {
      enable = lib.mkEnableOption "magpie's web page, served beside the gateway";

      host = lib.mkOption {
        type = lib.types.str;
        default = "127.0.0.1";
        description = "Address the page listens on.";
      };

      port = lib.mkOption {
        type = lib.types.port;
        default = 3430;
        description = "Port the page listens on.";
      };
    };

    settings = lib.mkOption {
      inherit (jsonFormat) type;
      default = {};
      example = {
        bareModelIDs = true;
        lan = true;
      };
      description = "Keys merged into magpie's writable `settings.json` before every start. Keys set in magpie itself are left alone, and a key removed here is removed there too. Values are stored in the Nix store.";
    };

    env = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {};
      example.MAGPIE_PUBLIC_URL = "https://magpie.example.com";
      description = "Environment variables passed to magpie. Values are stored in the Nix store.";
    };
  };

  mkService = {
    executable,
    packages ? [],
    account ? null,
    nixos ? {},
    darwin ? {},
  }:
    serviceLib.mkSpec {
      name = "magpie";
      description = "magpie model gateway";
      inherit packages account nixos darwin;

      process = {
        executable = lib.getExe (startScript executable);
        environment = {MAGPIE_ADDR = "${cfg.host}:${toString cfg.port}";} // cfg.env;
      };
    };
in {
  inherit options mkService;
}
