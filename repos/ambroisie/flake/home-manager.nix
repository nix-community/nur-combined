{ self, inputs, lib, ... }:
let
  defaultModules = [
    # Include generic settings
    "${self}/modules/home"
    {
      # Basic user information defaults
      home.username = lib.mkDefault "ambroisie";
      home.homeDirectory = lib.mkDefault "/home/ambroisie";

      # Make it a Linux installation by default
      targets.genericLinux.enable = lib.mkDefault true;

      # Enable home-manager
      programs.home-manager.enable = true;
    }
  ];

  mkHome = name: system: inputs.home-manager.lib.homeManagerConfiguration {
    # Work-around for home-manager
    # * not letting me set `lib` as an extraSpecialArgs
    # * not respecting `nixpkgs.overlays` [1]
    # [1]: https://github.com/nix-community/home-manager/issues/2954
    pkgs = import inputs.nixpkgs {
      inherit system;

      overlays = (lib.attrValues self.overlays) ++ [
        inputs.nur.overlays.default
      ];
    };

    modules = defaultModules ++ [
      "${self}/hosts/homes/${name}"
    ];

    extraSpecialArgs = {
      # Inject inputs to use them in global registry
      inherit inputs;
    };
  };

  homes = {
    "ambroisie@bazin" = "x86_64-linux";
    "ambroisie@mousqueton" = "x86_64-linux";
  };
in
{
  perSystem = { system, ... }: {
    # Work-around for https://github.com/nix-community/home-manager/issues/3075
    legacyPackages = {
      homeConfigurations =
        let
          filteredHomes = lib.filterAttrs (_: v: v == system) homes;
          allHomes = filteredHomes // {
            # Default configuration
            ambroisie = system;
          };
        in
        lib.mapAttrs mkHome allHomes;
    };
  };
}
