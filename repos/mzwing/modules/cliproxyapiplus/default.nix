{
  config,
  lib,
  pkgs,
  serviceLib,
  ...
}: let
  cfg = config.services.cliproxyapiplus;
  yamlFormat = pkgs.formats.yaml {};
  sources = pkgs.callPackage ../../_sources/generated.nix {};
  defaultPackage = pkgs.callPackage ../../pkgs/cliproxyapiplus {source = sources.cliproxyapiplus;};
  localPackages = {cliproxyapiplus = defaultPackage;};
  helpers = import ./helpers.nix {inherit pkgs;};

  defaultSettings = {
    port = 8317;
    remote-management.panel-github-repository = "https://github.com/kaitranntt/Cli-Proxy-API-Management-Center";
  };
  settingsFile = yamlFormat.generate "cliproxyapiplus-settings.yaml" cfg.settings;

  storeDir = builtins.storeDir or "/nix/store";
  isInStore = path: path == storeDir || lib.hasPrefix "${storeDir}/" path;

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
      helpers.mergeConfig
    ];
    text = ''
      umask 077

      data_dir=${lib.escapeShellArg cfg.dataDir}
      config_file="$data_dir/config.yaml"
      config_state="$data_dir/.cliproxyapiplus-nix-managed.json"
      config_backup="$data_dir/config.yaml.stateful"
      extra_args=(${lib.escapeShellArgs cfg.extraArgs})

      mkdir -p -- "$data_dir"
      ${lib.getExe helpers.mergeConfig} \
        "$config_file" \
        ${lib.escapeShellArg settingsFile} \
        "$config_state" \
        "$config_backup"${lib.concatMapStrings (path: " \\
        --api-key-file ${lib.escapeShellArg path}") cfg.apiKeysPaths}

      cd -- "$data_dir"
      exec ${lib.escapeShellArg (lib.getExe cfg.package)} \
        --config "$config_file" \
        "''${extra_args[@]}"
    '';
  };

  options = {
    enable = lib.mkEnableOption "CLIProxyAPI Plus system service";

    package = lib.mkPackageOption localPackages "cliproxyapiplus" {
      pkgsText = "inputs.nur.repos.mzwing";
      extraDescription = "It is installed system-wide and used by the system service.";
    };

    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/cliproxyapiplus";
      example = "/srv/cliproxyapiplus";
      description = ''
        Writable working directory containing `config.yaml`, authentication
        data, plugins, logs, and all other CLIProxyAPI Plus runtime state. It is
        also the home directory of the dedicated service account.
      '';
    };

    settings = lib.mkOption {
      inherit (yamlFormat) type;
      default = defaultSettings;
      apply = settings: lib.recursiveUpdate defaultSettings settings;
      example = lib.literalExpression ''
        {
          host = "localhost";
          port = 8317;
          auth-dir = "~/.cli-proxy-api";
          api-keys = ["replace-me"];
          routing.strategy = "round-robin";
        }
      '';
      description = ''
        Schema-agnostic YAML settings merged into the writable `config.yaml`
        before every start. The module neither enumerates nor validates
        CLIProxyAPI Plus-specific keys. Values are stored in the Nix store and
        must not contain secrets unless that exposure is acceptable. Values
        written by the management API remain intact unless their paths are
        explicitly managed here. The port defaults to 8317 and the management
        panel defaults to `kaitranntt/Cli-Proxy-API-Management-Center`.
      '';
    };

    apiKeysPaths = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      example = ["/run/secrets/cliproxyapiplus-api-keys"];
      description = ''
        External files (outside the Nix store) containing API keys, one per
        line. Files are read at every service start, in the given order, and
        the keys are merged into the `api-keys` value of the writable
        `config.yaml`. Blank lines and lines starting with `#` are ignored;
        leading and trailing whitespace is trimmed. Duplicates are kept.
        Symbolic links are followed, so sops-nix and agenix secrets can be
        used. A missing or unreadable file aborts the service start. This
        option is mutually exclusive with `settings.api-keys`. Changes to
        these files take effect on the next service restart. The service
        account must have read permission on the files.
      '';
    };

    env = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {};
      example.EXAMPLE = "example";
      description = ''
        Environment variables passed to CLIProxyAPI Plus. Values are included
        in the generated service configuration and the Nix store, so they must
        not contain secrets unless that exposure is acceptable.
      '';
    };

    extraArgs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      example = ["--local-model"];
      description = ''
        Additional command-line arguments for the server. The module owns the
        `--config` argument, so it cannot be supplied here. Values are stored in
        the Nix store and must not contain secrets.
      '';
    };
  };

  sharedConfig = {
    assertions = [
      {
        assertion = lib.hasPrefix "/" cfg.dataDir && !isInStore cfg.dataDir;
        message = "services.cliproxyapiplus.dataDir must be an absolute path outside the Nix store";
      }
      {
        assertion = !builtins.any hasConfigArgument cfg.extraArgs;
        message = "services.cliproxyapiplus.extraArgs cannot override --config";
      }
      {
        assertion = cfg.apiKeysPaths == [] || !(cfg.settings ? "api-keys");
        message = "services.cliproxyapiplus.apiKeysPaths and services.cliproxyapiplus.settings.api-keys are mutually exclusive";
      }
      {
        assertion = builtins.all (path: lib.hasPrefix "/" path && !isInStore path) cfg.apiKeysPaths;
        message = "services.cliproxyapiplus.apiKeysPaths entries must be absolute paths outside the Nix store";
      }
    ];
  };

  mkService = {
    account ? {},
    nixos ? {},
    darwin ? {},
  }:
    serviceLib.mkSpec {
      name = "cliproxyapiplus";
      description = "CLIProxyAPI Plus proxy service";
      packages = [cfg.package];

      process = {
        executable = lib.getExe startScript;
        environment = cfg.env;
        workingDirectory = cfg.dataDir;
        umask = "0077";
      };

      account =
        lib.recursiveUpdate {
          logicalName = "cliproxyapiplus";
          home = cfg.dataDir;
          description = "CLIProxyAPI Plus service user";
        }
        account;

      lifecycle = {
        autostart = true;
        restart = "on-failure";
        restartBackoffSeconds = 5;
        stopTimeoutSeconds = 90;
      };

      inherit nixos darwin;
    };
in {
  inherit options sharedConfig mkService;
}
