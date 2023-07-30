{ inputs, mkNixosHome }:

let
  self =
    { inputs
    , hostname
    , overlays ? []
    , users ? [ "root" ]
    , enable-hm ? false
    , hm-users ? []
    , enable-impermanence ? false
    , enable-impermanence-hm ? false
    , enable-sops ? false
    , enable-sops-hm ? false
    , extra-special-args ? {}
    }:

    let
      inherit (inputs.nixpkgs.lib) mkForce optionals;

      # Imports all indicated users
      importUsers = users: hostname: builtins.map (user: "${inputs.self}/system/users/${user}/${hostname}.nix") users;

      hostConfig = [
        "${inputs.self}/system/hosts/${hostname}/configuration.nix"
        "${inputs.self}/system/modules/personal"
        # Forcing hostname as we want to use the custom name
        ({ networking.hostName = mkForce hostname; })
      ];
      sopsConfig = [
        inputs.sops.nixosModules.sops
        "${inputs.self}/system/profiles/services/sops.nix"
        #"${inputs.self}/system/hosts/${hostname}/sops.nix"
      ];
      impermanenceConfig = [
        inputs.impermanence.nixosModules.impermanence
        "${inputs.self}/system/hosts/${hostname}/impermanence.nix"
      ];

    in inputs.nixos.lib.nixosSystem {
      modules = hostConfig
        ++ optionals (enable-hm) [ inputs.home-manager.nixosModules.home-manager ( mkNixosHome { inherit inputs hostname overlays enable-impermanence-hm enable-sops-hm; users = hm-users; } ) ]
        ++ optionals (enable-impermanence) impermanenceConfig
        ++ optionals (enable-sops) sopsConfig
        ++ (importUsers users hostname);
      specialArgs = { inherit hostname inputs; } // extra-special-args;
    };
in self
