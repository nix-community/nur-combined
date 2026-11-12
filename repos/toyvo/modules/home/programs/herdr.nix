{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkIf mkOption;

  cfg = config.programs.herdr-core;

  tomlFormat = pkgs.formats.toml { };
  generatedSettings = tomlFormat.generate "herdr-core-settings.toml" cfg.settings;
  # Match the merger's TOML serialization so unchanged mutable files can be
  # replaced by a store link when mutableSettings is disabled.
  settingsSource = pkgs.runCommand "herdr-core-config.toml" { } ''
    settings="$(${lib.getExe pkgs.jaq} --from toml --to toml '.' ${generatedSettings})"
    printf '%s\n' "$settings" > "$out"
  '';
  settingsPath = "${config.xdg.configHome}/herdr-core/config.toml";

  mutableSettingsActivation = lib.hm.generators.mkImpureConfigMerger {
    inherit pkgs;
    format = "toml";
    empty = "{}";
    jqOperation = "$dynamic * $static";
    path = settingsPath;
    staticSettings = settingsSource;
    mode = "600";
  };

  herdrBin = if cfg.package == null then "hc" else lib.escapeShellArg (lib.getExe cfg.package);
  reloadConfig = "${herdrBin} server restart || true";
in
{
  meta.maintainers = [ lib.maintainers.toyvo ];

  options.programs.herdr-core = {
    enable = lib.mkEnableOption "Herdr Core";

    package = lib.mkPackageOption pkgs "herdr-core" { nullable = true; };

    mutableSettings = mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = ''
        Whether to merge declared settings into a writable Herdr Core configuration
        file during activation, preserving settings added by Herdr or the user.
        Declared values, including arrays, take precedence. Removing a
        declaration does not remove it from the file. Comments and formatting
        are not preserved. New files have mode 0600; existing files retain
        their permissions.

        The default keeps the configuration file immutable. Switching back to
        immutable settings automatically replaces the writable file only when
        it is byte-identical to the declared settings. Changed files use Home
        Manager's normal collision and backup handling. Empty settings leave
        the file unmanaged.
      '';
    };

    settings = mkOption {
      inherit (tomlFormat) type;
      default = { };
      example = {
        shell = [ "nu" "-l" ];
        detach_key = "ctrl+\\";
        wait_timeout = 180.0;
        notes = true;
        notes_quiet = 3.0;
        draft_wait = 60.0;
        headless = "200x120";
        history_mb = 5.0;
        socket = "/run/user/1000/herdr-core.sock";
        machine_timeout = 30.0;
      };
      description = ''
        Configuration written to {file}`$XDG_CONFIG_HOME/herdr-core/config.toml`.
        See <https://herdr.dev/docs/configuration/> for the full list of options.
      '';
    };
  };

  config = mkIf cfg.enable {
    home = {
      packages = mkIf (cfg.package != null) [ cfg.package ];

      activation.herdrCoreMutableSettings = lib.mkIf (cfg.mutableSettings && cfg.settings != { }) (
        lib.hm.dag.entryAfter [ "linkGeneration" ] (
          mutableSettingsActivation
          + ''
            run ${reloadConfig}
          ''
        )
      );

      activation.herdrCoreImmutableSettings = lib.mkIf (!cfg.mutableSettings && cfg.settings != { }) (
        lib.hm.dag.entryBetween [ "linkGeneration" ] [ "writeBoundary" ] (
          lib.hm.generators.mkImpureConfigCleanup {
            file = config.xdg.configFile."herdr-core/config.toml";
          }
        )
      );
    };

    xdg.configFile."herdr-core/config.toml" = mkIf (!cfg.mutableSettings && cfg.settings != { }) {
      source = settingsSource;
      onChange = reloadConfig;
    };
  };
}
