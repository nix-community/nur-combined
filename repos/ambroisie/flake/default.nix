{ self
, futils
, home-manager
, nixpkgs
, nur
, ...
} @ inputs:
let
  inherit (self) lib;

  inherit (futils.lib) eachSystem system;

  mySystems = [
    system.aarch64-darwin
    system.aarch64-linux
    system.x86_64-darwin
    system.x86_64-linux
  ];

  eachMySystem = eachSystem mySystems;

  systemDependant = system: {
    apps = {
      diff-flake = futils.lib.mkApp { drv = self.packages.${system}.diff-flake; };
      default = self.apps.${system}.diff-flake;
    };

    checks = import ./checks.nix inputs system;

    devShells = import ./dev-shells.nix inputs system;

    packages = import ./packages.nix inputs system;

    # Work-around for https://github.com/nix-community/home-manager/issues/3075
    legacyPackages = {
      homeConfigurations = {
        ambroisie = home-manager.lib.homeManagerConfiguration {
          # Work-around for home-manager
          # * not letting me set `lib` as an extraSpecialArgs
          # * not respecting `nixpkgs.overlays` [1]
          # [1]: https://github.com/nix-community/home-manager/issues/2954
          pkgs = import nixpkgs {
            inherit system;

            overlays = (lib.attrValues self.overlays) ++ [
              nur.overlay
            ];
          };

          modules = [
            ./home
            {
              # Some Google specific configuration
              home.username = "ambroisie";
              home.homeDirectory = "/usr/local/google/home/ambroisie";

              # Let Home Manager install and manage itself.
              programs.home-manager.enable = true;
              # This is a generic linux install
              targets.genericLinux.enable = true;
            }
            # Some tooling (e.g: SSH) need to use this library
            {
              home.sessionVariables = {
                LD_PRELOAD = "/lib/x86_64-linux-gnu/libnss_cache.so.2\${LD_PRELOAD:+:}$LD_PRELOAD";
              };
            }
            {
              my.home = {
                gpg.enable = false;
              };
            }
          ];

          extraSpecialArgs = {
            # Inject inputs to use them in global registry
            inherit inputs;
          };
        };
      };
    };
  };

  systemIndependant = {
    lib = import ./lib.nix inputs;

    overlays = import ./overlays.nix inputs;

    nixosConfigurations = import ./nixos.nix inputs;
  };
in
(eachMySystem systemDependant) // systemIndependant
