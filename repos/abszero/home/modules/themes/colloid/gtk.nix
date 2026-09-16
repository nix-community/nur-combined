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
  inherit (config.lib.catppuccin) toTitleCase;
  cfg = config.abszero.themes.colloid.gtk;

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
  options.abszero.themes.colloid.gtk = {
    enable = mkEnableOption "colloid gtk theme with catppuccin scheme";

    accent = mkOption {
      type = types.enum accents;
      default = "default";
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

  config.gtk.theme = mkIf cfg.enable {
    name =
      "Colloid"
      + optionalString (cfg.accent != "default") (mkSuffix cfg.accent)
      + optionalString (cfg.size == "compact") "-Compact";
    package = pkgs.colloid-gtk-theme.override {
      themeVariants = [ cfg.accent ];
      sizeVariants = [ cfg.size ];
      inherit (cfg) tweaks;
    };
  };
}
