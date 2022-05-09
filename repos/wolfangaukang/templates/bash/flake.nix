{
  description = "Template for Bash projects";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-21.11";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, utils }:
    let
      # General project settings
      name = "project";

    in
    (utils.lib.eachSystem [ "x86_64-linux" "aarch64-linux" ] (system:
      let
        pkgs = system: import nixpkgs {
          inherit system;
          # Picking from ./nix/project.nix to have a single maintenance point
          overlays = [
            (final: prev: {
              ${name} = prev.callPackage ./nix/${name}.nix { };
            })
          ];
        };

      in rec {
        legacyPackages = pkgs system;

        packages = utils.lib.flattenTree {
          inherit (legacyPackages) project;
        };
        defaultPackage = packages.${name};

        apps.${name} = utils.lib.mkApp { drv = packages.${name}; };
        defaultApp = apps.${name};

        devShell = legacyPackages.mkShell {
          buildInputs = with legacyPackages; [ shellcheck ];
        };
      }
    ));
}
