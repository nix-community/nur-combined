{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.pumpkin;
  tomlFormat = pkgs.formats.toml {};
  sources = pkgs.callPackage ../../_sources/generated.nix {};
  defaultPackage = pkgs.callPackage ../../pkgs/pumpkin {source = sources.pumpkin;};
  localPackages = {pumpkin = defaultPackage;};
  helpers = import ./helpers.nix {inherit pkgs;};

  settingsFile = tomlFormat.generate "pumpkin-settings.toml" cfg.settings;
  whitelistFile = pkgs.writeText "pumpkin-whitelist.json" (
    builtins.toJSON (
      lib.mapAttrsToList (name: uuid: {inherit name uuid;}) cfg.whitelist
    )
  );

  storeDir = builtins.storeDir or "/nix/store";
  isInStore = path: path == storeDir || lib.hasPrefix "${storeDir}/" path;
  invalidEnvNames = builtins.filter (
    name: builtins.match "^[A-Za-z_][A-Za-z0-9_]*$" name == null
  ) (builtins.attrNames cfg.env);

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
      config_state="$data_dir/.pumpkin-home-manager-managed.json"
      config_backup="$data_dir/pumpkin.toml.stateful"
      whitelist_file="$data_dir/data/whitelist.json"
      whitelist_state="$data_dir/data/.pumpkin-home-manager-whitelist.json"
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
in {
  options.services.pumpkin = {
    enable = lib.mkEnableOption "Pumpkin Minecraft server user service";

    package = lib.mkPackageOption localPackages "pumpkin" {
      pkgsText = "inputs.nur.repos.mzwing";
      extraDescription = "It is installed and used by the user service.";
    };

    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "${config.xdg.dataHome}/pumpkin";
      defaultText = lib.literalExpression ''"''${config.xdg.dataHome}/pumpkin"'';
      example = lib.literalExpression ''"''${config.home.homeDirectory}/servers/pumpkin"'';
      description = ''
        Writable working directory containing `pumpkin.toml`, worlds, plugins,
        logs, and all other Pumpkin runtime state. The directory is created
        when the service starts.
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

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = lib.hasPrefix "/" cfg.dataDir && !isInStore cfg.dataDir;
        message = "services.pumpkin.dataDir must be an absolute writable path outside the Nix store";
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
      {
        assertion = invalidEnvNames == [];
        message = "services.pumpkin.env contains invalid variable names: ${lib.concatStringsSep ", " invalidEnvNames}";
      }
      {
        assertion = lib.meta.availableOn pkgs.stdenv.hostPlatform cfg.package;
        message = "services.pumpkin.package is not available on ${pkgs.stdenv.hostPlatform.system}";
      }
      {
        assertion = pkgs.stdenv.hostPlatform.isLinux || pkgs.stdenv.hostPlatform.isDarwin;
        message = "services.pumpkin supports only Linux and Darwin";
      }
    ];

    home.packages = [cfg.package];

    systemd.user.services.pumpkin = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
      Unit = {
        Description = "Pumpkin Minecraft server";
        After = ["network-online.target"];
        Wants = ["network-online.target"];
      };
      Service = {
        ExecStart = lib.getExe startScript;
        Environment = lib.mapAttrsToList (name: value: "${name}=${value}") cfg.env;
        Restart = "on-failure";
        RestartSec = 5;
        TimeoutStopSec = 120;
        UMask = "0077";
      };
      Install.WantedBy = ["default.target"];
    };

    launchd.agents.pumpkin = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
      enable = true;
      config = {
        ProgramArguments = [(lib.getExe startScript)];
        RunAtLoad = true;
        KeepAlive = {
          Crashed = true;
          SuccessfulExit = false;
        };
        ProcessType = "Background";
        EnvironmentVariables = cfg.env;
        Umask = 63;
        StandardOutPath = "${config.home.homeDirectory}/Library/Logs/Pumpkin.out.log";
        StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/Pumpkin.err.log";
      };
    };
  };
}
