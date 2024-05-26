# Options on top of catppuccin/nix
# Accent and default flavor options are added by catppuccin/nix
{ config, lib, ... }:

let
  inherit (builtins) substring;
  inherit (lib)
    types
    mkOption
    mkDefault
    toUpper
    ;
  absCfg = config.abszero.catppuccin;

  optionModule = types.submodule {
    options = {
      polarity = mkOption {
        type = types.enum [
          "light"
          "dark"
        ];
        default = "light";
        description = ''
          Whether to use light or dark theme for modules that don't support
          automatic theme switching, or when useSystemPolarity is turned off.
        '';
      };
      useSystemPolarity = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Whether to automatically switch between light and dark themes based
          on the system theme polarity.
        '';
      };
      lightFlavor = mkOption {
        type = types.enum [
          "frappe"
          "latte"
          "macchiato"
          "mocha"
        ];
        default = "latte";
        description = ''
          The light theme flavor (latte, frappe, macchiato, mocha).
        '';
      };
      darkFlavor = mkOption {
        type = types.enum [
          "frappe"
          "latte"
          "macchiato"
          "mocha"
        ];
        default = "macchiato";
        description = ''
          The dark theme flavor (latte, frappe, macchiato, mocha).
        '';
      };
    };
  };
in

{
  options.abszero.catppuccin = mkOption {
    type = optionModule;
    default = { };
    description = "Configurations for catppuccin.";
  };

  config = {
    catppuccin = {
      # Enable all modules by default
      enable = mkDefault true;
      flavor = absCfg."${absCfg.polarity}Flavor";
    };

    lib.catppuccin.toTitleCase = s: toUpper (substring 0 1 s) + substring 1 100 s;
  };
}
