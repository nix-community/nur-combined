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
    optionalString
    ;
  inherit (builtins) elem;
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
in

{
  imports = [ ../../../../lib/modules/themes/catppuccin/catppuccin.nix ];

  options.abszero.themes.catppuccin.gtk = {
    enable = mkEnableOption "colloid gtk theme with catppuccin scheme";

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
          "rimless"
          "normal"
          "float"
        ]);
      default = [ ];
      description = "Tweaks of the theme.";
    };
  };

  config = mkIf cfg.gtk.enable {
    abszero.themes.catppuccin.enable = true;

    gtk.theme = {
      name =
        "Colloid"
        + optionalString (cfg.gtk.accent != "default") (mkSuffix cfg.gtk.accent)
        + optionalString (cfg.gtk.size == "compact") "-Compact"
        + "-Catppuccin";
      package = pkgs.colloid-gtk-theme.override {
        themeVariants = [ cfg.gtk.accent ];
        sizeVariants = [ cfg.gtk.size ];
        tweaks = [ "catppuccin" ] ++ cfg.gtk.tweaks;
      };
    };
  };
}
