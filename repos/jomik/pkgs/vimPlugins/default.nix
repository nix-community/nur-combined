{ config, callPackage, lib, vimUtils }:

let
  inherit (vimUtils) buildVimPluginFrom2Nix;

  plugins = callPackage ./generated.nix {
    inherit buildVimPluginFrom2Nix overrides;
  };

  # TL;DR
  # * Add your plugin to ./vim-plugin-names
  # * sort -udf ./vim-plugin-names > sorted && mv sorted vim-plugin-names
  # * run ./update.py
  #
  # If additional modifications to the build process are required,
  # add to ./overrides.nix.
  overrides = callPackage ./overrides.nix {
    inherit buildVimPluginFrom2Nix;
  };

  aliases = lib.optionalAttrs (config.allowAliases or true) (import ./aliases.nix lib plugins);
in { recurseForDerivations = true; } // plugins // aliases
