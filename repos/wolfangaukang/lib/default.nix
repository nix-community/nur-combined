{ inputs, ... }:

let
  inherit (inputs.nixpkgs.lib) genAttrs optionals systems;
  #pkgs_systems = systems.flakeExposed; 
  pkgs_systems = [ "x86_64-linux" ];

in
{
  importAttrset = path: builtins.mapAttrs (_: import) (import path);

  forAllSystems = f: genAttrs pkgs_systems (system: f system);

  mkSystem =
    { hostname
    , username
    , inputs
    , extra-modules ? []
    , overlays ? []
    , enable-hm ? true
    }:

    {
      modules = [ ../hosts/${hostname}/configuration.nix ]
        ++ extra-modules
        ++ optionals (enable-hm) [ inputs.home-manager.nixosModules.home-manager ( import ../hosts/common/hm-module.nix { inherit inputs hostname overlays username; } ) ];
    };

  mkHome =
    { hostname
    , username
    , system
    , overlays ? []
    , channel ? inputs.nixpkgs
    , pkgs ? channel.legacyPackages.${system}
    }:

    let
      inherit (inputs.home-manager.lib) homeManagerConfiguration;

    in homeManagerConfiguration {
      inherit pkgs system username;
      extraSpecialArgs = { inherit username; };
      homeDirectory = "/home/${username}";
      configuration = { ... }: {
        imports = [
          ../hosts/${hostname}/home-manager.nix
          ../modules/home-manager/personal
        ];
        nixpkgs.overlays = overlays;
      };
    };
}
