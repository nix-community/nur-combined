{
  description = "Geonix - geospatial environment for Nix";

  nixConfig.extra-substituters = [ "https://geonix.cachix.org?trusted=1" ];
  nixConfig.bash-prompt = "[geonix] > ";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";

  outputs = { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "i686-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "armv6l-linux"
        "armv7l-linux"
      ];

      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
      pkgs = forAllSystems (system: nixpkgs.legacyPackages.${system});

      # allow insecure QGIS dependency (QtWebkit)
      insecurePackages = [ "qtwebkit-5.212.0-alpha4" ];

    in
    {
      packages = forAllSystems (system: import ./default.nix {
        pkgs = import nixpkgs {
          inherit system;
          config = { permittedInsecurePackages = insecurePackages; };
        };
      });

      defaultApp.x86_64-linux = self.packages.x86_64-linux.qgis;

      devShells = forAllSystems (system: {

        pkgs = import nixpkgs {
          inherit system;
          config = { permittedInsecurePackages = insecurePackages; };
        };

        default = pkgs.${system}.mkShellNoCC {
          packages = with self.packages.${system}; [
            gdal
            geos
            pdal
            proj
            qgis
          ];
        };
      });

      # formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;
    };
}
