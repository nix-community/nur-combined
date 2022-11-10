{ inputs, ... }:

let
  inherit (inputs.nixpkgs.lib) genAttrs optionals systems;
  #pkgs_systems = systems.flakeExposed; 
  pkgs_systems = [ "x86_64-linux" ];

in
{
  importAttrset = path: builtins.mapAttrs (_: import) (import path);

  importHmUsers = users: builtins.listToAttrs (map (user: { name = "users.${user}"; value = import ../home/${user}/home.nix; }) users);

  forAllSystems = f: genAttrs pkgs_systems (system: f system);

  mkSystem =
    { hostname
    , username
    , inputs
    , extra-modules ? []
    , overlays ? []
    , enable-hm ? true
    , enable-impermanence ? true
    }:

    let
      hostConfig = [ ../hosts/${hostname}/configuration.nix ];

    in
    {
      modules = hostConfig
        ++ optionals (enable-hm) [ inputs.home-manager.nixosModules.home-manager ( import ../hosts/common/hm-module.nix { inherit inputs hostname overlays username; } ) ]
        ++ optionals (enable-impermanence) [
          inputs.impermanence.nixosModules.impermanence
          ../hosts/${hostname}/impermanence.nix
        ]
        ++ extra-modules;
      extraArgs = { inherit hostname; };
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
      inherit pkgs;
      extraSpecialArgs = { inherit username; };
      modules = [
        ../hosts/${hostname}/home-manager.nix
        ../modules/home-manager/personal
        {
          home = {
            username = username;
            homeDirectory = "/home/${username}";
          };
          nixpkgs.overlays = overlays;
        }
      ];
    };
}
