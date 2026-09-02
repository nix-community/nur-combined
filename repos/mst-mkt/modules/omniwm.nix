{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.omniwm;
  tomlFormat = pkgs.formats.toml { };
in

{
  options.programs.omniwm = {
    enable = lib.mkEnableOption "OmniWM, a macOS tiling window manager inspired by Niri and Hyprland";

    package = lib.mkPackageOption pkgs "omniwm" { };

    settings = lib.mkOption {
      type = with lib.types; nullOr (either path tomlFormat.type);
      default = null;
      example = lib.literalExpression ''
        {
          general = {
            updateChecksEnabled = false;
          };
          niri = {
            visibleContainerCount = 3;
          };
        }
      '';
      description = ''
        OmniWM settings written to
        {file}`$XDG_CONFIG_HOME/omniwm/settings.toml`.

        Can be either an attribute set (serialized to TOML) or
        a path to an existing TOML file.

        When `null` (the default), the settings file is not
        managed and can be edited freely via the GUI.

        See <https://github.com/BarutSRB/OmniWM> for available options.
      '';
    };

    launchd = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to manage OmniWM with a launchd agent.";
      };

      keepAlive = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether the launchd agent should be kept alive.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      (lib.hm.assertions.assertPlatform "programs.omniwm" pkgs lib.platforms.darwin)
    ];

    home.packages = [ cfg.package ];

    xdg.configFile."omniwm/settings.toml" = lib.mkIf (cfg.settings != null) {
      source =
        if lib.hm.strings.isPathLike cfg.settings then
          cfg.settings
        else
          tomlFormat.generate "omniwm-settings.toml" cfg.settings;
      force = true;
    };

    launchd.agents.omniwm = {
      inherit (cfg.launchd) enable;
      config = {
        Program = "${cfg.package}/Applications/OmniWM.app/Contents/MacOS/OmniWM";
        KeepAlive = cfg.launchd.keepAlive;
        RunAtLoad = true;
        StandardOutPath = "/tmp/omniwm.log";
        StandardErrorPath = "/tmp/omniwm.err.log";
      };
    };
  };
}
