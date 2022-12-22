{ inputs, ... }:

let
  inherit (inputs.nixpkgs.lib) genAttrs mapAttrsToList optionals systems;
  #pkgs_systems = systems.flakeExposed; 
  pkgs_systems = [ "x86_64-linux" ];

in
rec {
  # This will be helpful to import all modules from a certain place
  importAttrset = path: builtins.mapAttrs (_: import) (import path);

  # This will be useful to import the hm users dynamically according to a list provided
  # TODO: See how to handle hostname specific homes
  importHmUsers = users: hostname: builtins.listToAttrs (map (user: { name = "${user}"; value = import ../users/${user}/home/${hostname}.nix; }) users);

  # Same as above, but for system users
  importUsers = users: hostname: builtins.map (user: ../users/${user}/system/${hostname}.nix) users;

  # Useful to apply certain configurations to a list of system archs
  forAllSystems = f: genAttrs pkgs_systems (system: f system);

  mkHomeNixos =
    { inputs
    , users
    , hostname
    , overlays ? []
    , enable-sab ? true
    , enable-impermanence-hm ? false
    }:

    let
      personalModules = [ ../modules/home-manager/personal ];
      hmModules = (mapAttrsToList (_: value: value) inputs.self.hmModules);

    in {
      home-manager = {
        #extraSpecialArgs = { inherit username; };
        # TODO: Handle these with parameters
        useGlobalPkgs = true;
        useUserPackages = true;
        sharedModules = personalModules
          ++ hmModules
          ++ optionals (enable-sab) [ inputs.sab.hmModule ]
          ++ optionals (enable-impermanence-hm) [ inputs.impermanence.nixosModules.home-manager.impermanence ];
        #users."${username}" = import ../${hostname}/home-manager.nix;
      } // { users = (importHmUsers users hostname); };
      nixpkgs = {
        config.allowUnfree = true;
        overlays = overlays;
      };
    };

  mkSystem =
    { inputs
    , hostname
    , extra-modules ? []
    , overlays ? []
    , users ? [ "root" ]
    , enable-hm ? false
    , hm-users ? []
    , enable-impermanence ? false
    , enable-impermanence-hm ? false
    , enable-sops ? false
    , enable-server-secrets ? false
    }:

    let
      hostConfig = [ ../hosts/${hostname}/configuration.nix ];
      sopsConfig = [
        inputs.sops.nixosModules.sops
        ../profiles/nixos/sops.nix
      ] ++ optionals (enable-server-secrets) [ ../hosts/${hostname}/sops.nix ];
      impermanenceConfig = [
        inputs.impermanence.nixosModules.impermanence
        ../hosts/${hostname}/impermanence.nix
      ];

    in
    {
      modules = hostConfig
        ++ optionals (enable-hm) [ inputs.home-manager.nixosModules.home-manager ( mkHomeNixos { inherit inputs hostname overlays enable-impermanence-hm; users = hm-users; } ) ]
        ++ optionals (enable-impermanence) impermanenceConfig
        ++ optionals (enable-sops) sopsConfig
        ++ (importUsers users hostname)
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
        ../users/${username}/home/${hostname}.nix
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
