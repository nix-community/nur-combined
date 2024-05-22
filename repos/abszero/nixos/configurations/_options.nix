{ inputs, config, lib, withSystem, ... }:

let
  inherit (inputs) nixpkgs;
  inherit (lib) types mkOption mapAttrs flatten;
  inherit (lib.abszero.filesystem) toModuleList;
  cfg = config.nixosConfigurations;

  configModule = { name, ... }: {
    options = {
      system = mkOption {
        type = types.nonEmptyStr;
        description = "System architecture";
      };
      hostName = mkOption {
        type = types.nonEmptyStr;
        default = name;
        description = ''
          Name of the computer. Defaults to the name of the NixOS configuration.
        '';
      };
      modules = mkOption {
        type = with types; listOf deferredModule;
        default = [ ];
        description = "List of modules specific to this NixOS configuration";
      };
    };
  };
in

{
  options.nixosConfigurations = mkOption {
    type = with types; attrsOf (submodule configModule);
    description = "Abstracted home configuration options";
  };

  config.flake.nixosConfigurations = mapAttrs
    (_: c: withSystem c.system
      ({ system, ... }: nixpkgs.lib.nixosSystem {
        inherit system lib;
        specialArgs = { inherit inputs; };
        modules = flatten [
          inputs.disko.nixosModules.disko
          inputs.catppuccin.nixosModules.catppuccin
          (toModuleList ../modules/config)
          (toModuleList ../modules/system)
          (toModuleList ../modules/programs)
          (toModuleList ../modules/services)
          (toModuleList ../modules/i18n)
          (toModuleList ../modules/virtualisation)
          c.modules
          {
            nixpkgs.overlays = [
              (_: prev: import ../../pkgs { pkgs = prev; })
            ];
            networking = { inherit (c) hostName; };
          }
        ];
      }))
    cfg;
}
