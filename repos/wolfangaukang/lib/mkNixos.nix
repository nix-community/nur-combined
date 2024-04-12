{ inputs, mkNixosHome }:

let
  self =
    { inputs
    , hostname
    , pkgs
    , users ? [ "root" ]
    , enable-hm ? false
    , hm-users ? [ ]
    , enable-impermanence ? false
    , enable-impermanence-hm ? false
    , enable-sops ? false
    , enable-sops-hm ? false
    , extra-special-args ? { }
    }:

    let
      inherit (inputs.nixpkgs.lib) mkForce optionals;

      # Imports all indicated users per hostname configuration
      importUsers = users: hostname: builtins.map (user: "${inputs.self}/system/users/${user}/hosts/${hostname}.nix") users;
      importSopsSettingsPerUser = users: builtins.map (user: "${inputs.self}/system/users/${user}/sops.nix") users;


      hostConfig = [
        "${inputs.self}/system/hosts/${hostname}/configuration.nix"
        "${inputs.self}/system/modules/personal"
        "${inputs.self}/system/profiles/base.nix"
        # Forcing hostname as we want to use the custom name
        ({ networking.hostName = mkForce hostname; })
      ];
      sopsConfig = [
        inputs.sops.nixosModules.sops
        "${inputs.self}/system/profiles/sops.nix"
      ] ++ importSopsSettingsPerUser users;
      impermanenceConfig = [
        inputs.impermanence.nixosModules.impermanence
        "${inputs.self}/system/hosts/${hostname}/impermanence.nix"
      ];

    in
    inputs.nixos.lib.nixosSystem {
      modules = hostConfig
        ++ optionals (enable-hm) [ inputs.home-manager.nixosModules.home-manager (mkNixosHome { inherit inputs hostname pkgs enable-impermanence-hm enable-sops-hm; users = hm-users; }) ]
        ++ optionals (enable-impermanence) impermanenceConfig
        ++ optionals (enable-sops) sopsConfig
        ++ (importUsers users hostname);
      specialArgs = { inherit hostname inputs pkgs; } // extra-special-args;
    };
in
self
