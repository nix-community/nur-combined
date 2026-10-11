{ config, lib, pkgs, ... }:

let
  cfg = config.quriosity.sddm-themes.where-is-my-sddm-theme;

  presets = {
    classic = { };
    classic_nocursor = {
      passwordInputCursorVisible = false;
    };
    grey = {
      passwordInputWidth = "0.33";
      passwordInputBackground = "#a0a0a0";
      passwordInputRadius = 7;
      passwordFontSize = 28;
      passwordCursorColor = "#ffffff";
      usersFontSize = 32;
      backgroundFill = "#404040";
    };
    lightgrey = {
      passwordInputWidth = "0.33";
      passwordInputBackground = "#a0a0a0";
      passwordInputRadius = 7;
      passwordFontSize = 28;
      passwordCursorColor = "#000000";
      usersFontSize = 32;
      backgroundFill = "#cccccc";
      basicTextColor = "#000000";
    };
    blue = {
      passwordInputWidth = "0.25";
      passwordInputBackground = "#7b9fe7";
      passwordInputRadius = 7;
      passwordFontSize = 28;
      passwordCursorColor = "#ffffff";
      usersFontSize = 32;
      backgroundFill = "#8aadf4";
    };
    nord = {
      passwordInputBackground = "#434c5e";
      passwordInputRadius = 40;
      passwordFontSize = 64;
      passwordCursorColor = "#81a1c1";
      wrongPasswordBorderColor = "#bf616a";
      showUserRealNameByDefault = false;
      backgroundFill = "#2e3440";
      basicTextColor = "#81a1c1";
    };
    rose-pine-moon = {
      passwordInputBackground = "#393552";
      passwordInputRadius = 80;
      passwordInputBorderWidth = 4;
      passwordInputBorderColor = "#c4a7e7";
      passwordInputCursorVisible = false;
      passwordCursorColor = "#2a283e";
      passwordTextColor = "#e0def4";
      wrongPasswordBorderRadius = 80;
      wrongPasswordBorderColor = "#eb6f92";
      showSessionsByDefault = true;
      backgroundFill = "#232136";
      basicTextColor = "#e0def4";
      font = "CaskaydiaCove Nerd Font Mono";
    };
    tree = {
      passwordInputWidth = "0.25";
      passwordInputBackground = "#60ffffff";
      passwordInputRadius = 10;
      passwordInputCursorVisible = false;
      passwordFontSize = 28;
      usersFontSize = 32;
      background = "tree.png";
    };
  };

  userConfig =
    lib.recursiveUpdate
      (lib.recursiveUpdate
        (lib.optionalAttrs (cfg.preset != null) { General = presets.${cfg.preset}; })
        cfg.settings)
      (lib.optionalAttrs (cfg.backgroundImage != null) {
        General.background = "${cfg.backgroundImage}";
      });

  themeConfUser = (pkgs.formats.ini { }).generate "wims-theme-theme.conf.user" userConfig;

  baseTheme = cfg.package;

  configuredTheme = pkgs.runCommand "wims-theme-configured" { } (
    ''
      mkdir -p $out/share/sddm/themes
      cp -r ${baseTheme}/share/sddm/themes/wims-theme $out/share/sddm/themes/wims-theme
      chmod -R u+w $out/share/sddm/themes/wims-theme
      cp ${themeConfUser} $out/share/sddm/themes/wims-theme/theme.conf.user
    ''
    + lib.optionalString (cfg.preset == "tree") ''
      cp ${baseTheme}/share/sddm/themes/wims-theme/example_configs/tree.png $out/share/sddm/themes/wims-theme/tree.png
    ''
  );
in
{
  options.quriosity.sddm-themes.where-is-my-sddm-theme = {
    enable = lib.mkEnableOption "Where is my SDDM theme";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.callPackage ../pkgs/sddm-themes/where-is-my-sddm-theme { };
      description = "Where is my SDDM theme package to use as a base.";
    };

    preset = lib.mkOption {
      type = lib.types.nullOr (lib.types.enum (builtins.attrNames presets));
      default = null;
      example = "nord";
      description = ''
        Use one of the predefined configurations shipped with the theme
        instead of the default one.

        Available presets: ${lib.concatStringsSep ", " (map (p: "`${p}`") (builtins.attrNames presets))}.
      '';
    };

    settings = lib.mkOption {
      type = (pkgs.formats.ini { }).type;
      default = { };
      example = {
        General = {
          backgroundFill = "#1e1e2e";
          basicTextColor = "#cdd6f4";
          passwordInputRadius = 12;
        };
      };
      description = ''
        Additional theme configuration written to `theme.conf.user`.
        These values override the packaged `theme.conf` (and the selected
        `preset`). Only non-empty values take effect.
      '';
    };

    backgroundImage = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      example = "/path/to/my-wallpaper.png";
      description = ''
        Background image to use for the theme. It is referenced by its
        absolute store path in the `background` option of the theme config.
        If both `backgroundImage` and `settings.General.background` are set,
        `backgroundImage` takes precedence.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ configuredTheme ];

    services.displayManager.sddm.theme = lib.mkDefault "wims-theme";
  };
}