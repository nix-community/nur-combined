{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib)
    types
    mkOption
    mkEnableOption
    mkIf
    optional
    optionalString
    ;
  inherit (builtins) elem;
  inherit (lib.abszero.modules) mkExternalEnableOption;
  inherit (config.lib.catppuccin) toTitleCase;
  cfg = config.abszero.themes.catppuccin;
  ctpCfg = config.catppuccin;

  mkSuffix = s: "-${toTitleCase s}";

  accents = [
    "default"
    "purple"
    "pink"
    "red"
    "orange"
    "yellow"
    "green"
    "teal"
    "grey"
  ];

  polarity = if cfg.gtk.flavor == "latte" then "light" else "dark";

  flavorTweak = optionalString (
    cfg.gtk.flavor == "frappe" || cfg.gtk.flavor == "macchiato"
  ) cfg.gtk.flavor;
in

{
  imports = [ ../../../../lib/modules/themes/catppuccin/catppuccin.nix ];

  options.abszero.themes.catppuccin.gtk = {
    enable = mkExternalEnableOption config "magnetic-catppuccin-gtk theme";

    gnomeShellTheme = mkEnableOption "Whether to use the gnome shell theme.";

    flavor = mkOption {
      type = types.enum [
        "latte"
        "frappe"
        "macchiato"
        "mocha"
      ];
      default = ctpCfg.flavor;
      description = "Flavor of the theme.";
    };

    accent = mkOption {
      type = types.enum accents;
      default = if elem ctpCfg.accent accents then ctpCfg.accent else "default";
      description = "Accent of the theme. Not all accents are supported.";
    };

    size = mkOption {
      type = types.enum [
        "standard"
        "compact"
      ];
      default = "standard";
      description = "Size of the theme.";
    };

    tweaks = mkOption {
      type =
        with types;
        listOf (enum [
          "black"
          "float"
          "outline"
          "macos"
        ]);
      default = [ ];
      description = "Tweaks of the theme.";
    };
  };

  config = mkIf cfg.gtk.enable {
    abszero.themes.catppuccin.enable = true;

    gtk.theme = {
      name =
        "Catppuccin-GTK"
        + optionalString (cfg.gtk.accent != "default") (mkSuffix cfg.gtk.accent)
        + mkSuffix polarity
        + optionalString (cfg.gtk.size == "compact") "-Compact"
        + optionalString (flavorTweak != "") (mkSuffix flavorTweak);
      package = pkgs.magnetic-catppuccin-gtk.override {
        accent = [ cfg.gtk.accent ];
        shade = polarity;
        inherit (cfg.gtk) size;
        tweaks = cfg.gtk.tweaks ++ optional (flavorTweak != "") flavorTweak;
      };
    };

    home.packages = with pkgs; mkIf cfg.gtk.gnomeShellTheme [ gnomeExtensions.user-themes ];

    dconf.settings = mkIf cfg.gtk.gnomeShellTheme {
      "org/gnome/shell" = {
        disable-user-extensions = false;
        enabled-extensions = [ "user-theme@gnome-shell-extensions.gcampax.github.com" ];
      };
      "org/gnome/shell/extensions/user-theme" = {
        inherit (config.gtk.theme) name;
      };
      "org/gnome/desktop/interface" = {
        color-scheme = if cfg.polarity == "light" then "default" else "prefer-dark";
      };
    };
  };
}
