{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.programs.cliproxyapiplus;
  yamlFormat = pkgs.formats.yaml {};
  sources = pkgs.callPackage ../../_sources/generated.nix {};
  defaultPackage = pkgs.callPackage ../../pkgs/cliproxyapiplus {source = sources.cliproxyapiplus;};

  defaultSettings = {
    port = 8317;
    remote-management.panel-github-repository = "https://github.com/kaitranntt/Cli-Proxy-API-Management-Center";
  };
  settingsFile = yamlFormat.generate "cliproxyapiplus-settings.yaml" (
    lib.recursiveUpdate defaultSettings cfg.settings
  );
  mergeConfig = import ./merge.nix {inherit pkgs;};

  storeDir = builtins.storeDir or "/nix/store";
  isInStore = path: path == storeDir || lib.hasPrefix "${storeDir}/" path;
  invalidEnvNames = builtins.filter (
    name: builtins.match "^[A-Za-z_][A-Za-z0-9_]*$" name == null
  ) (builtins.attrNames cfg.env);

  hasConfigArgument = arg:
    arg
    == "-config"
    || arg == "--config"
    || lib.hasPrefix "-config=" arg
    || lib.hasPrefix "--config=" arg;

  startScript = pkgs.writeShellApplication {
    name = "cliproxyapiplus-start";
    runtimeInputs = [
      pkgs.coreutils
      mergeConfig
    ];
    text = ''
      config_path=${lib.escapeShellArg cfg.configPath}
      settings_file=${lib.escapeShellArg settingsFile}
      extra_args=(${lib.escapeShellArgs cfg.extraArgs})
      merge_args=("$config_path" "$settings_file")
      ${lib.optionalString (cfg.apiKeysFile != null) ''
        merge_args+=(${lib.escapeShellArg cfg.apiKeysFile})
      ''}

      ${lib.getExe mergeConfig} "''${merge_args[@]}"

      cd -- "$(dirname -- "$config_path")"
      exec ${lib.escapeShellArg (lib.getExe cfg.package)} \
        --config "$config_path" \
        "''${extra_args[@]}"
    '';
  };
in {
  options.programs.cliproxyapiplus = {
    enable = lib.mkEnableOption "CLIProxyAPI Plus program and user service";

    package = lib.mkOption {
      type = lib.types.package;
      default = defaultPackage;
      description = "CLIProxyAPI Plus package to install and run.";
    };

    configPath = lib.mkOption {
      type = lib.types.str;
      default = "${config.xdg.configHome}/cliproxyapiplus/config.yaml";
      defaultText = lib.literalExpression ''"''${config.xdg.configHome}/cliproxyapiplus/config.yaml"'';
      description = ''
        Writable runtime configuration path. The management API updates this
        file in place, so it must not be a Home Manager managed store symlink.
      '';
    };

    settings = lib.mkOption {
      inherit (yamlFormat) type;
      default = defaultSettings;
      example = lib.literalExpression ''
        {
          host = "localhost";
          port = 8317;
          auth-dir = "''${config.home.homeDirectory}/.cli-proxy-api";
          routing.strategy = "round-robin";
        }
      '';
      description = ''
        YAML settings merged into the writable runtime configuration before
        every service start. The module does not validate or filter these
        settings. They are stored in the Nix store and override matching runtime
        values. The port defaults to 8317 and the management panel defaults to
        `kaitranntt/Cli-Proxy-API-Management-Center`.
      '';
    };

    apiKeysFile = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = lib.literalExpression "config.sops.secrets.cliproxyapiplus-api-keys.path";
      description = ''
        Optional external YAML or JSON file containing a non-empty sequence of
        non-empty API key strings. Its contents are injected into the top-level
        `api-keys` setting at service start without entering the Nix store.
      '';
    };

    env = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {};
      example = {
        MANAGEMENT_PASSWORD = "example";
      };
      description = ''
        Environment variables passed directly to the background service. Values
        are included in the generated service configuration and the Nix store.
      '';
    };

    extraArgs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      example = ["--local-model"];
      description = ''
        Additional command-line arguments for the background server. The module
        owns the `--config` argument, so it cannot be supplied here. Values are
        stored in the Nix store and must not contain secrets.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = lib.hasPrefix "/" cfg.configPath && !isInStore cfg.configPath;
        message = "programs.cliproxyapiplus.configPath must be an absolute writable path outside the Nix store";
      }
      {
        assertion = cfg.apiKeysFile == null || (lib.hasPrefix "/" cfg.apiKeysFile && !isInStore cfg.apiKeysFile);
        message = "programs.cliproxyapiplus.apiKeysFile must be an absolute path outside the Nix store";
      }
      {
        assertion = invalidEnvNames == [];
        message = "programs.cliproxyapiplus.env contains invalid variable names: ${lib.concatStringsSep ", " invalidEnvNames}";
      }
      {
        assertion = !builtins.any hasConfigArgument cfg.extraArgs;
        message = "programs.cliproxyapiplus.extraArgs cannot override --config";
      }
    ];

    home.packages = [cfg.package];

    systemd.user.services.cliproxyapiplus = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
      Unit = {
        Description = "CLIProxyAPI Plus proxy service";
        After = ["network-online.target"];
        Wants = ["network-online.target"];
      };
      Service = {
        ExecStart = lib.getExe startScript;
        Environment = lib.mapAttrsToList (name: value: "${name}=${lib.escapeShellArg value}") cfg.env;
        Restart = "on-failure";
        RestartSec = 5;
        UMask = "0077";
      };
      Install.WantedBy = ["default.target"];
    };

    launchd.agents.cliproxyapiplus = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
      enable = true;
      config = {
        ProgramArguments = [lib.getExe startScript];
        RunAtLoad = true;
        KeepAlive = {
          Crashed = true;
          SuccessfulExit = false;
        };
        ProcessType = "Background";
        EnvironmentVariables = cfg.env;
        Umask = 63;
        StandardOutPath = "${config.home.homeDirectory}/Library/Logs/CLIProxyAPIPlus.out.log";
        StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/CLIProxyAPIPlus.err.log";
      };
    };
  };
}
