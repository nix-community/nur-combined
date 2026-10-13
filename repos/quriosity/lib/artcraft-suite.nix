{ lib }:

let
  # The Craft App Suite: the twelve apps the launcher knows about, in the launcher's
  # display order (crates/core/src/catalog.rs). The launcher itself is not part of SUITE.
  appIds = [
    "photocraft"
    "vectorcraft"
    "filmcraft"
    "lightcraft"
    "pdfcraft"
    "effectcraft"
    "designcraft"
    "wordcraft"
    "deckcraft"
    "gridcraft"
    "cadcraft"
    "soundcraft"
    "figcraft"
  ];

  # ThemeChoice (crates/ui-egui/src/theme.rs): System | Dark | Light.
  themeToRon = {
    system = "System";
    dark = "Dark";
    light = "Light";
  };

  # Interface language codes from the launcher's registry (crates/ui-egui/src/i18n/lang.rs).
  # "auto" follows the system locale.
  languageCodes = {
    auto = "auto";
    en = "en";
    ru = "ru";
    zh-CN = "zh-CN";
    de = "de";
    fr = "fr";
    pt-BR = "pt-BR";
  };

  # The RON value eframe stores under the "settings" key. A partial struct is fine: Settings is
  # `#[serde(default)]`, so fields we don't set fall back to the launcher's own defaults (the
  # launcher's settings_file.rs test loads the launcher with only "(notify:true)").
  mkSettingsRon = { theme, language, closeToTray }:
    "(theme:${themeToRon.${theme}},language:${builtins.toJSON language},close_to_tray:${lib.boolToString closeToTray})";

  # `app.ron`: eframe's map of keys (window state, egui memory, the launcher's settings) to RON
  # strings, in the folder eframe::storage_dir picks: $XDG_DATA_HOME/ai.storyteller.artcraft-launcher.
  # Only "settings" is seeded; the launcher keeps whatever else it writes there.
  mkAppRon = args: builtins.toJSON { settings = mkSettingsRon args; };

  # The XDG autostart entry the launcher's own "start at login" toggle writes. `--hidden` starts it
  # in the tray without opening a window, exactly as login::HIDDEN_FLAG does.
  mkAutostart = launcher: ''
    [Desktop Entry]
    Type=Application
    Name=ArtCraft Launcher
    Comment=Install and update the Craft App Suite
    Exec="${launcher}/bin/artcraft-launcher" --hidden
    Icon=ai.storyteller.artcraft-launcher
    Terminal=false
    X-GNOME-Autostart-enabled=true
  '';

  # The options both the NixOS and the Home Manager module expose, so they stay in step.
  mkOptions = { pkgs }: {
    enable = lib.mkEnableOption "the ArtCraft Launcher and a selection of Craft apps";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.callPackage ../pkgs/apps/artcraft-suite/artcraft-launcher { };
      description = "The ArtCraft Launcher package.";
    };

    packages = lib.mkOption {
      type = lib.types.listOf (lib.types.enum appIds);
      default = [ ];
      example = [ "photocraft" "pdfcraft" "wordcraft" ];
      description = ''
        Craft apps to install. They are built from source by this repository and the
        launcher picks them up as installed regardless of how they were installed.
      '';
    };

    theme = lib.mkOption {
      type = lib.types.enum (builtins.attrNames themeToRon);
      default = "system";
      description = "Launcher appearance: `system` follows the desktop's light/dark setting.";
    };

    language = lib.mkOption {
      type = lib.types.enum (builtins.attrNames languageCodes);
      default = "auto";
      description = "Launcher interface language; `auto` follows the system locale.";
    };

    closeToTray = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Keep the launcher running in the tray when its window is closed.";
    };

    autostart.enable = lib.mkEnableOption "starting the ArtCraft Launcher at login (in the tray)";
  };
in
{
  inherit appIds themeToRon languageCodes mkSettingsRon mkAppRon mkAutostart mkOptions;
}
