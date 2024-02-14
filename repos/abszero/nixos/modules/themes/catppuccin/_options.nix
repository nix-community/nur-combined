{ config, lib, ... }:

let
  inherit (builtins) getAttr substring;
  inherit (lib) types mkOption toUpper;
  cfg = config.abszero.themes.catppuccin;

  optionModule = types.submodule {
    options = {
      defaultVariant = mkOption {
        type = types.enum [ "light" "dark" ];
        default = "light";
        description = ''
          Whether to use light or dark variant for modules that don't support
          automatic theme switching, or when automaticThemeSwitching is turned
          off.
        '';
      };
      automaticThemeSwitching = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Whether to automatically switch between light and dark variants based
          on the system theme.
        '';
      };
      lightVariant = mkOption {
        type = types.enum [ "latte" "frappe" "macchiato" "mocha" ];
        default = "latte";
        description = ''
          The light theme variant (latte, frappe, macchiato, mocha).
        '';
      };
      darkVariant = mkOption {
        type = types.enum [ "latte" "frappe" "macchiato" "mocha" ];
        default = "macchiato";
        description = ''
          The dark theme variant (latte, frappe, macchiato, mocha).
        '';
      };
      accent = mkOption {
        type = types.nonEmptyStr;
        default = "mauve";
        description = ''
          The primary accent color.
        '';
      };
    };
  };
in

{
  options.abszero.themes.catppuccin = mkOption {
    type = optionModule;
    default = { };
    description = "Configurations for catppuccin.";
  };

  config.lib.catppuccin = {
    getVariant = getAttr
      (cfg.defaultVariant + "Variant")
      cfg;
    toTitleCase = s: toUpper (substring 0 1 s) + substring 1 100 s;
  };
}
