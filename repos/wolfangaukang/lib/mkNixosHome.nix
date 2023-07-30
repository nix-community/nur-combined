{ inputs }:

let self =
  { inputs
  , users
  , hostname
  , overlays ? []
  , enable-sab ? true
  , enable-impermanence-hm ? false
  , enable-sops-hm ? false
  }:

  let
    inherit (inputs.nixpkgs.lib) mapAttrsToList optionals;

    # This will be useful to import the hm users dynamically according to a list provided
    # TODO: See how to handle hostname specific homes
    importHmUsers = users: hostname: builtins.listToAttrs (map (user: { name = "${user}"; value = import "${inputs.self}/home/users/${user}/hosts/${hostname}.nix"; }) users);

    hmModules = (mapAttrsToList (_: value: value) inputs.self.homeManagerModules);

  in {
    home-manager = {
      #extraSpecialArgs = { inherit username; };
      # TODO: Handle these with parameters
      useGlobalPkgs = true;
      useUserPackages = true;
      extraSpecialArgs = { inherit inputs; };
      sharedModules = hmModules
        ++ optionals (enable-sab) [ inputs.sab.hmModule ]
        ++ optionals (enable-impermanence-hm) [ inputs.impermanence.nixosModules.home-manager.impermanence ]
        ++ optionals (enable-sops-hm) [ inputs.sops.homeManagerModules.sops ];
      users = (importHmUsers users hostname);
    }; #// { users = (importHmUsers users hostname); };
    nixpkgs = {
      config.allowUnfree = true;
      overlays = overlays;
    };
  };
in self
