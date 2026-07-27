{
  description = "Geospatial NIX";

  nixConfig = {
    extra-substituters = [
      "https://geonix.cachix.org"
    ];
    extra-trusted-public-keys = [
      "geonix.cachix.org-1:iyhIXkDLYLXbMhL3X3qOLBtRF8HEyAbhPXjjPeYsCl0="
    ];
    bash-prompt = "\\[\\033[1m\\][geonix]\\[\\033\[m\\]\\040\\w >\\040";
  };

  inputs = {
    geonix.url = "path:../../.";
    nixpkgs.follows = "geonix/nixpkgs";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {

      systems = [ "x86_64-linux" ];

      perSystem = { config, self', inputs', pkgs, system, ... }: {
        packages =
          let
            geopkgs = inputs.geonix.lib.customizePackages {
              nixpkgs = pkgs;
              geopkgs = inputs.geonix.packages.${pkgs.system};
              overridesFile = ./overrides.nix;
            };
          in
          {
            gdal = geopkgs.gdal;
          };
      };

      flake = { };
    };
}
