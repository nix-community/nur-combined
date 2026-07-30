{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.cliproxyapiplus;
  yamlFormat = pkgs.formats.yaml {};
  sources = pkgs.callPackage ../../_sources/generated.nix {};
  defaultPackage = pkgs.callPackage ../../pkgs/cliproxyapiplus {source = sources.cliproxyapiplus;};

  managedSettingsFile = yamlFormat.generate "cliproxyapiplus-managed.yaml" cfg.managedSettings;
  mergeConfig = import ./merge.nix {inherit pkgs;};

  allowedManagedKeys = [
    "host"
    "port"
    "tls"
    "remote-management"
    "auth-dir"
    "debug"
    "commercial-mode"
    "logging-to-file"
    "logs-max-total-size-mb"
    "usage-statistics-enabled"
    "proxy-url"
    "force-model-prefix"
    "request-retry"
    "max-retry-interval"
    "disable-image-generation"
    "quota-exceeded"
    "routing"
    "ws-auth"
    "nonstream-keepalive-interval"
    "codex-instructions-enabled"
    "streaming"
    "redis-usage-queue-retention-seconds"
  ];
  allowedNestedKeys = {
    tls = ["enable" "cert" "key"];
    remote-management = ["allow-remote" "disable-control-panel" "panel-github-repository"];
    quota-exceeded = ["switch-project" "switch-preview-model" "antigravity-credits"];
    routing = ["strategy" "session-affinity" "session-affinity-ttl"];
    streaming = ["keepalive-seconds" "bootstrap-retries"];
  };
  configuredManagedKeys = builtins.attrNames cfg.managedSettings;
  unknownManagedKeys = builtins.filter (name: !builtins.elem name allowedManagedKeys) configuredManagedKeys;
  nestedSettingsAreAttrs = builtins.all (
    name: !builtins.hasAttr name cfg.managedSettings || builtins.isAttrs cfg.managedSettings.${name}
  ) (builtins.attrNames allowedNestedKeys);
  unknownNestedKeys = lib.concatMap (
    name:
      if !builtins.hasAttr name cfg.managedSettings || !builtins.isAttrs cfg.managedSettings.${name}
      then []
      else
        map (child: "${name}.${child}") (
          builtins.filter
          (child: !builtins.elem child allowedNestedKeys.${name})
          (builtins.attrNames cfg.managedSettings.${name})
        )
  ) (builtins.attrNames allowedNestedKeys);

  storeDir = builtins.storeDir or "/nix/store";
  isInStore = path: path == storeDir || lib.hasPrefix "${storeDir}/" path;
  proxyURL = cfg.managedSettings."proxy-url" or "";
  proxyURLContainsCredentials =
    builtins.isString proxyURL
    && builtins.match "^[A-Za-z][A-Za-z0-9+.-]*://[^/@]+@.*" proxyURL != null;

  hasConfigArgument = arg:
    arg
    == "-config"
    || arg == "--config"
    || lib.hasPrefix "-config=" arg
    || lib.hasPrefix "--config=" arg;

  startScript = pkgs.writeShellApplication {
    name = "cliproxyapiplus-start";
    runtimeInputs = [mergeConfig];
    text = ''
      config_file=${lib.escapeShellArg cfg.configFile}
      managed_file=${lib.escapeShellArg managedSettingsFile}
      extra_args=(${lib.escapeShellArgs cfg.extraArgs})
      merge_args=("$config_file" "$managed_file")
      ${lib.optionalString (cfg.apiKeysFile != null) ''
        merge_args+=(${lib.escapeShellArg cfg.apiKeysFile})
      ''}

      ${lib.getExe mergeConfig} "''${merge_args[@]}"

      ${lib.optionalString (cfg.environmentFile != null) ''
        environment_file=${lib.escapeShellArg cfg.environmentFile}
        if [[ ! -f "$environment_file" || ! -r "$environment_file" ]]; then
          echo "cliproxyapiplus: environment file is not a readable regular file: $environment_file" >&2
          exit 1
        fi
        while IFS= read -r line || [[ -n "$line" ]]; do
          line="''${line%$'\r'}"
          [[ -z "$line" || "$line" == \#* ]] && continue
          name="''${line%%=*}"
          value="''${line#*=}"
          if [[ "$line" != *=* ]] || [[ ! "$name" =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]]; then
            echo "cliproxyapiplus: invalid environment assignment in $environment_file" >&2
            exit 1
          fi
          export "$name=$value"
        done <"$environment_file"
      ''}

      cd -- "$(dirname -- "$config_file")"
      exec ${lib.escapeShellArg (lib.getExe cfg.package)} \
        --config "$config_file" \
        "''${extra_args[@]}"
    '';
  };
in {
  options.services.cliproxyapiplus = {
    enable = lib.mkEnableOption "CLIProxyAPI Plus user service";

    package = lib.mkOption {
      type = lib.types.package;
      default = defaultPackage;
      description = "CLIProxyAPI Plus package to run.";
    };

    configFile = lib.mkOption {
      type = lib.types.str;
      default = "${config.xdg.configHome}/cliproxyapiplus/config.yaml";
      defaultText = lib.literalExpression ''"''${config.xdg.configHome}/cliproxyapiplus/config.yaml"'';
      description = ''
        Writable runtime configuration file. The management API updates this
        file in place, so it must not be a Home Manager managed store symlink.
      '';
    };

    managedSettings = lib.mkOption {
      inherit (yamlFormat) type;
      default = {};
      example = lib.literalExpression ''
        {
          host = "localhost";
          port = 8317;
          auth-dir = "''${config.home.homeDirectory}/.cli-proxy-api";
          routing.strategy = "round-robin";
        }
      '';
      description = ''
        Non-secret settings merged into the writable runtime configuration
        before every service start. These values are stored in the Nix store
        and override matching runtime values. Only the documented stable keys
        are accepted; provider credentials, model lists, plugins, and top-level
        API keys must remain outside this option.
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

    environmentFile = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "/run/secrets/cliproxyapiplus.env";
      description = ''
        Optional external `KEY=VALUE` file loaded immediately before starting
        the service. Names must be shell identifiers; values are used literally
        without shell evaluation or quote processing. Blank lines and lines
        beginning with `#` are ignored. It can provide `MANAGEMENT_PASSWORD`
        without placing the value in the Nix store.
      '';
    };

    extraArgs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      example = ["--local-model"];
      description = ''
        Additional command-line arguments. The module owns the `--config`
        argument, so it cannot be supplied here.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = lib.hasPrefix "/" cfg.configFile && !isInStore cfg.configFile;
        message = "services.cliproxyapiplus.configFile must be an absolute writable path outside the Nix store";
      }
      {
        assertion = cfg.apiKeysFile == null || (lib.hasPrefix "/" cfg.apiKeysFile && !isInStore cfg.apiKeysFile);
        message = "services.cliproxyapiplus.apiKeysFile must be an absolute path outside the Nix store";
      }
      {
        assertion = cfg.environmentFile == null || (lib.hasPrefix "/" cfg.environmentFile && !isInStore cfg.environmentFile);
        message = "services.cliproxyapiplus.environmentFile must be an absolute path outside the Nix store";
      }
      {
        assertion = unknownManagedKeys == [];
        message = "services.cliproxyapiplus.managedSettings contains unsupported or runtime-owned keys: ${lib.concatStringsSep ", " unknownManagedKeys}";
      }
      {
        assertion = nestedSettingsAreAttrs;
        message = "services.cliproxyapiplus.managedSettings nested sections must be attribute sets";
      }
      {
        assertion = unknownNestedKeys == [];
        message = "services.cliproxyapiplus.managedSettings contains unsupported nested keys: ${lib.concatStringsSep ", " unknownNestedKeys}";
      }
      {
        assertion = !proxyURLContainsCredentials;
        message = "services.cliproxyapiplus.managedSettings.proxy-url must not contain URL userinfo because managed settings enter the Nix store";
      }
      {
        assertion = !builtins.any hasConfigArgument cfg.extraArgs;
        message = "services.cliproxyapiplus.extraArgs cannot override --config";
      }
    ];

    warnings = lib.optional (cfg.apiKeysFile == null) ''
      services.cliproxyapiplus.apiKeysFile is unset; the module will preserve
      any runtime top-level api-keys instead of managing them.
    '';

    home.packages = [cfg.package];

    systemd.user.services.cliproxyapiplus = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
      Unit = {
        Description = "CLIProxyAPI Plus proxy service";
        After = ["network-online.target"];
        Wants = ["network-online.target"];
        X-Restart-Triggers = [
          managedSettingsFile
          startScript
        ];
      };
      Service = {
        ExecStart = lib.getExe startScript;
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
        Umask = 63;
        StandardOutPath = "${config.home.homeDirectory}/Library/Logs/CLIProxyAPIPlus.out.log";
        StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/CLIProxyAPIPlus.err.log";
      };
    };
  };
}
