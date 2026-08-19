{
  inputs,
  config,
  lib,
  withSystem,
  ...
}:

let
  inherit (inputs) nixpkgs-patcher;
  inherit (lib)
    types
    mkOption
    mapAttrs
    flatten
    ;
  inherit (lib.abszero.filesystem) toModuleList;
  cfg = config.abszero.nixosConfigurations;

  configModule =
    { name, ... }:
    {
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
  options = {
    abszero.nixosConfigurations = mkOption {
      type = with types; attrsOf (submodule configModule);
      description = "Abstracted home configuration options";
    };
    # Declare option as anything to allow recursively merging multiple values
    flake.deploy = mkOption {
      type = types.anything;
    };
  };

  config.flake.nixosConfigurations = mapAttrs (
    _: c:
    withSystem c.system (
      { system, ... }:
      nixpkgs-patcher.lib.nixosSystem {
        inherit system lib;
        nixpkgsPatcher = { inherit inputs; };
        specialArgs = { inherit inputs; };
        modules = flatten [
          inputs.nixified-ai.nixosModules.comfyui
          inputs.driftwm.nixosModules.driftwm
          inputs.wisp.nixosModules.wisp
          inputs.charmbracelet.nixosModules.crush
          inputs.sops.nixosModules.sops
          inputs.disko.nixosModules.disko
          inputs.lanzaboote.nixosModules.lanzaboote
          inputs.catppuccin.nixosModules.catppuccin
          (toModuleList ../../../lib/modules)
          (toModuleList ../../modules)
          c.modules
          {
            nixpkgs.overlays = [
              (_: prev: import ../../../pkgs { pkgs = prev; })
              inputs.nix-cachyos-kernel.overlays.default
            ];
            networking = { inherit (c) hostName; };
          }
        ];
      }
    )
  ) cfg;
}
