{
  inputs,
  config,
  lib,
  withSystem,
  ...
}:

let
  inherit (inputs) home-manager;
  inherit (lib)
    types
    mkOption
    mapAttrs
    flatten
    splitString
    ;
  inherit (builtins) head;
  inherit (lib.abszero.filesystem) toModuleList;
  cfg = config.homeConfigurations;

  configModule =
    { name, config, ... }:
    {
      options = {
        system = mkOption {
          type = types.nonEmptyStr;
          description = "System architecture";
        };
        username = mkOption {
          type = types.nonEmptyStr;
          default = head (splitString "@" name);
          description = "Username";
        };
        homeDirectory = mkOption {
          type = types.nonEmptyStr;
          default = "/home/${config.username}";
          description = "Absolute path to user's home";
        };
        modules = mkOption {
          type = with types; listOf deferredModule;
          default = [ ];
          description = "List of modules specific to this home configuration";
        };
      };
    };
in

{
  options.homeConfigurations = mkOption {
    type = with types; attrsOf (submodule configModule);
    description = "Abstracted home configuration options";
  };

  config.flake.homeConfigurations = mapAttrs (
    _: c:
    withSystem c.system (
      { pkgs, ... }:
      home-manager.lib.homeManagerConfiguration {
        inherit pkgs lib;
        extraSpecialArgs = {
          inherit inputs;
        };
        modules = flatten [
          # Install only the config as the program is installed by NixOS module
          inputs.niri.homeModules.config
          inputs.nix-index-database.hmModules.nix-index
          inputs.catppuccin.homeModules.catppuccin
          (toModuleList ../../lib/modules)
          (toModuleList ../modules)
          c.modules
          {
            abszero.enableExternalModulesByDefault = false;
            nixpkgs.overlays = [
              (_: prev: import ../../pkgs { pkgs = prev; })
              inputs.niri.overlays.niri
            ];
            home = {
              inherit (c) username homeDirectory;
            };
          }
        ];
      }
    )
  ) cfg;
}
