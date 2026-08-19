{
  inputs,
  config,
  lib,
  withSystem,
  ...
}:

let
  inherit (inputs) nixpkgs-patcher home-manager;
  inherit (lib)
    types
    mkOption
    mapAttrs
    flatten
    splitString
    ;
  inherit (builtins) head;
  inherit (lib.abszero.filesystem) toModuleList;
  cfg = config.abszero.homeConfigurations;

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
  options.abszero.homeConfigurations = mkOption {
    type = with types; attrsOf (submodule configModule);
    description = "Abstracted home configuration options";
  };

  config.flake.homeConfigurations = mapAttrs (
    _: c:
    withSystem c.system (
      { system, ... }:
      let
        nixpkgs = nixpkgs-patcher.lib.patchNixpkgs { inherit system inputs; };
        pkgs = import nixpkgs { inherit system; };
      in
      home-manager.lib.homeManagerConfiguration {
        inherit pkgs lib;
        extraSpecialArgs = { inherit inputs; };
        modules = flatten [
          inputs.zen-browser.homeModules.beta
          inputs.nix-index-database.homeModules.nix-index
          inputs.sops.homeModules.sops
          inputs.catppuccin.homeModules.catppuccin
          (toModuleList ../../../lib/modules)
          (toModuleList ../../modules)
          c.modules
          {
            nixpkgs.overlays = [
              (_: prev: import ../../../pkgs { pkgs = prev; })
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
