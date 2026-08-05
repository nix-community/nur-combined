{
  config,
  lib,
  pkgs,
  serviceLib,
  ...
}: let
  cfg = config.services.pumpkin;
  tomlFormat = pkgs.formats.toml {};
  localPackages = {
    pumpkin = (import ../../internal/discover.nix {inherit (pkgs) lib;}).package {
      inherit pkgs;
      name = "pumpkin";
    };
  };
  helpers = import ./helpers.nix {inherit pkgs;};

  settingsFile = tomlFormat.generate "pumpkin-settings.toml" cfg.settings;
  whitelistFile = pkgs.writeText "pumpkin-whitelist.json" (
    builtins.toJSON (
      lib.mapAttrsToList (name: uuid: {inherit name uuid;}) cfg.whitelist
    )
  );

  storeDir = builtins.storeDir or "/nix/store";
  isInStore = path: path == storeDir || lib.hasPrefix "${storeDir}/" path;

  startScript = pkgs.writeShellApplication {
    name = "pumpkin-start";
    runtimeInputs = [
      pkgs.coreutils
      helpers.manageWhitelist
      helpers.mergeConfig
    ];
    text = ''
      umask 077

      data_dir=${lib.escapeShellArg cfg.dataDir}
      config_file="$data_dir/pumpkin.toml"
      config_state="$data_dir/.pumpkin-nix-managed.json"
      config_backup="$data_dir/pumpkin.toml.stateful"
      whitelist_file="$data_dir/data/whitelist.json"
      whitelist_state="$data_dir/data/.pumpkin-nix-whitelist.json"
      whitelist_backup="$data_dir/data/whitelist.json.stateful"

      mkdir -p -- "$data_dir/data"

      merge_args=(
        "$config_file"
        ${lib.escapeShellArg settingsFile}
        "$config_state"
        "$config_backup"
      )
      ${lib.optionalString (cfg.secretSettingsFile != null) ''
        merge_args+=(${lib.escapeShellArg cfg.secretSettingsFile})
      ''}
      ${lib.getExe helpers.mergeConfig} "''${merge_args[@]}"

      ${
        if cfg.whitelist == null
        then ''
          ${lib.getExe helpers.manageWhitelist} \
            unmanaged \
            "$whitelist_file" \
            "$whitelist_state" \
            "$whitelist_backup"
        ''
        else ''
          ${lib.getExe helpers.manageWhitelist} \
            managed \
            "$whitelist_file" \
            "$whitelist_state" \
            "$whitelist_backup" \
            ${lib.escapeShellArg whitelistFile}
        ''
      }

      cd -- "$data_dir"
      exec ${lib.escapeShellArg (lib.getExe cfg.package)}
    '';
  };

  minecraftUUID =
    lib.types.strMatching "[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}"
    // {
      description = "Minecraft UUID";
    };

  options = {
    enable = lib.mkEnableOption "Pumpkin Minecraft server system service";

    package = lib.mkPackageOption localPackages "pumpkin" {
      pkgsText = "inputs.nur.repos.mzwing";
      extraDescription = "It is installed system-wide and used by the system service.";
    };

    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/pumpkin";
      example = "/srv/pumpkin";
      description = ''
        Writable working directory containing `pumpkin.toml`, worlds, plugins,
        logs, and all other Pumpkin runtime state. The directory is created for
        the dedicated service account when the module is enabled.
      '';
    };

    settings = lib.mkOption {
      inherit (tomlFormat) type;
      default = {};
      example = lib.literalExpression ''
        {
          default_level_name = "world";
          networking.java.address = "0.0.0.0:25565";
          networking.bedrock.enabled = false;
        }
      '';
      description = ''
        Schema-agnostic settings merged into the writable `pumpkin.toml`
        before every start. The module neither enumerates nor validates
        Pumpkin-specific keys. Values are stored in the Nix store and must not
        contain secrets. Values that Pumpkin adds at runtime remain intact
        unless their paths are explicitly managed here.
      '';
    };

    secretSettingsFile = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = lib.literalExpression "config.sops.secrets.pumpkin-settings.path";
      description = ''
        Optional external TOML file merged after `settings` at service start.
        Its contents do not enter the Nix store, but Pumpkin requires the
        merged secrets to exist as plaintext in the writable `pumpkin.toml`.
      '';
    };

    whitelist = lib.mkOption {
      type = lib.types.nullOr (lib.types.attrsOf minecraftUUID);
      default = null;
      example = {
        Steve = "8667ba71-b85a-4004-af54-457a9734eed7";
      };
      description = ''
        Declaratively managed whitelist as a mapping from player names to UUIDs.
        `null` leaves `data/whitelist.json` under Pumpkin's control. An attribute
        set, including an empty one, replaces it before every start. Enabling
        whitelist enforcement remains the responsibility of `settings`.
      '';
    };

    env = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default.RUST_BACKTRACE = "1";
      example.RUST_LOG = "info";
      description = ''
        Environment variables passed to Pumpkin. Values are included in the
        generated service configuration and the Nix store, so they must not
        contain secrets.
      '';
    };
  };

  sharedConfig = {
    assertions = [
      {
        assertion = !isInStore cfg.dataDir;
        message = "services.pumpkin.dataDir must be outside the Nix store";
      }
      {
        assertion =
          cfg.secretSettingsFile
          == null
          || (cfg.secretSettingsFile
            != ""
            && lib.hasPrefix "/" cfg.secretSettingsFile
            && !isInStore cfg.secretSettingsFile);
        message = "services.pumpkin.secretSettingsFile must be an absolute path outside the Nix store";
      }
    ];
  };

  mkService = {
    account ? {},
    nixos ? {},
    darwin ? {},
  }:
    serviceLib.mkSpec {
      name = "pumpkin";
      description = "Pumpkin Minecraft server";
      packages = [cfg.package];

      process = {
        executable = lib.getExe startScript;
        environment = cfg.env;
        workingDirectory = cfg.dataDir;
        umask = "0077";
      };

      account =
        lib.recursiveUpdate {
          logicalName = "pumpkin";
          home = cfg.dataDir;
          description = "Pumpkin Minecraft server service user";
        }
        account;

      lifecycle = {
        autostart = true;
        restart = "on-failure";
        restartBackoffSeconds = 5;
        stopTimeoutSeconds = 120;
      };

      inherit nixos darwin;
    };
in {
  inherit options sharedConfig mkService;
}
