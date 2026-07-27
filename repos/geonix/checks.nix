{ self, system, nixpkgs, pkgs }:

{
  # package tests
  inherit (self.packages.${system}.gdal.tests)
    ogrinfo-version
    gdalinfo-version
    ogrinfo-format-geopackage
    gdalinfo-format-geotiff
    vector-file
    raster-file;

  inherit (self.packages.${system}.geos.tests) geos;
  inherit (self.packages.${system}.pdal.tests) pdal;
  inherit (self.packages.${system}.proj.tests) proj;
  inherit (self.packages.${system}.grass.tests) grass;

  # nixos tests
  test-qgis = pkgs.nixosTest (import ./tests/nixos/qgis.nix {
    inherit nixpkgs pkgs;
    lib = nixpkgs.lib;
    qgisPackage = self.packages.${system}.qgis;
  });

  test-qgis-ltr = pkgs.nixosTest (import ./tests/nixos/qgis.nix {
    inherit nixpkgs pkgs;
    lib = nixpkgs.lib;
    qgisPackage = self.packages.${system}.qgis-ltr;
  });

  test-nixgl = pkgs.nixosTest (import ./tests/nixos/nixgl.nix {
    inherit nixpkgs pkgs;
    lib = nixpkgs.lib;
    nixGL = self.packages.${system}.nixGL;
  });

  # TODO: add postgis test
}
