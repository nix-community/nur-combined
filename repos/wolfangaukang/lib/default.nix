{ inputs, ... }:

let
  inherit (inputs.nixpkgs.lib) genAttrs getBin mapAttrsToList mkForce optionals systems;
  #pkgs_systems = systems.flakeExposed;
  pkgs_systems = [ "x86_64-linux" ];

in
rec {
  # This will be helpful to import all modules from a certain place
  importAttrset = path: builtins.mapAttrs (_: import) (import path);

  # This will be useful to import the hm users dynamically according to a list provided
  # TODO: See how to handle hostname specific homes
  importHmUsers = users: hostname: builtins.listToAttrs (map (user: { name = "${user}"; value = import "${inputs.self}/home/users/${user}/${hostname}.nix"; }) users);

  # Same as above, but for system users
  importUsers = users: hostname: builtins.map (user: "${inputs.self}/system/users/${user}/${hostname}.nix") users;

  # Useful to apply certain configurations to a list of system archs
  forAllSystems = f: genAttrs pkgs_systems (system: f system);

  mkHomeNixos =
    { inputs
    , users
    , hostname
    , overlays ? []
    , enable-sab ? true
    , enable-impermanence-hm ? false
    , enable-sops-hm ? false
    }:

    let
      personalModules = [ "${inputs.self}/home/modules/personal" ];
      hmModules = (mapAttrsToList (_: value: value) inputs.self.hmModules);

    in {
      home-manager = {
        #extraSpecialArgs = { inherit username; };
        # TODO: Handle these with parameters
        useGlobalPkgs = true;
        useUserPackages = true;
        extraSpecialArgs = { inherit inputs; };
        sharedModules = personalModules
          ++ hmModules
          ++ optionals (enable-sab) [ inputs.sab.hmModule ]
          ++ optionals (enable-impermanence-hm) [ inputs.impermanence.nixosModules.home-manager.impermanence ]
          ++ optionals (enable-sops-hm) [ inputs.sops.homeManagerModules.sops ];
      } // { users = (importHmUsers users hostname); };
      nixpkgs = {
        config.allowUnfree = true;
        overlays = overlays;
      };
    };

  mkSystem =
    { inputs
    , hostname
    , kernel ? null
    , extra-modules ? []
    , overlays ? []
    , users ? [ "root" ]
    , enable-hm ? false
    , hm-users ? []
    , enable-impermanence ? false
    , enable-impermanence-hm ? false
    , enable-sops ? false
    , enable-sops-hm ? false
    , enable-server-secrets ? false
    }:

    let
      hostConfig = [
        "${inputs.self}/system/hosts/${hostname}/configuration.nix"
        # Forcing hostname as we want to use the custom name
        ({ networking.hostName = mkForce hostname; })
      ] ++ (if kernel != null then [ ({ boot.kernelPackages = kernel; }) ] else []);
      sopsConfig = [
        inputs.sops.nixosModules.sops
        "${inputs.self}/system/profiles/services/sops.nix"
      ] ++ optionals (enable-server-secrets) [ "${inputs.self}/system/hosts/${hostname}/sops.nix" ];
      impermanenceConfig = [
        inputs.impermanence.nixosModules.impermanence
        "${inputs.self}/system/hosts/${hostname}/impermanence.nix"
      ];

    in
    {
      modules = hostConfig
        ++ optionals (enable-hm) [ inputs.home-manager.nixosModules.home-manager ( mkHomeNixos { inherit inputs hostname overlays enable-impermanence-hm enable-sops-hm; users = hm-users; } ) ]
        ++ optionals (enable-impermanence) impermanenceConfig
        ++ optionals (enable-sops) sopsConfig
        ++ (importUsers users hostname)
        ++ extra-modules;
      specialArgs = { inherit hostname inputs; };
    };

  mkHome =
    { hostname
    , username
    , system
    , inputs
    , overlays ? []
    , channel ? inputs.nixpkgs
    , pkgs ? channel.legacyPackages.${system}
    }:

    let
      inherit (inputs.home-manager.lib) homeManagerConfiguration;

    in homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = { inherit username inputs; };
      modules = [
        "${inputs.self}/home/users/${username}/${hostname}.nix"
        "${inputs.self}/home/modules/personal"
        {
          home = {
            username = username;
            homeDirectory = "/home/${username}";
          };
          nixpkgs.overlays = overlays;
        }
      ];
    };

 generateFirejailWrappedBinaryConfig =
   {
     pkg,
     pkg_name,
     bin_name ? pkg_name,
     enable_desktop ? false,
     desktop_file_name ? pkg_name
   }:

   let
     path = "${getBin pkg}";
   in { executable = "${path}/bin/${bin_name}"; }
   // (optionals enable_desktop) { desktop = "${path}/share/applications/${desktop_file_name}.desktop"; };
}
