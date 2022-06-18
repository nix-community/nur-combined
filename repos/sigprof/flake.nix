{
  description = "Personal NUR repository of @sigprof";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    let
      nurPackageOverlay = import ./overlay.nix;
    in
    {
      overlay = final: prev: nurPackageOverlay final prev;
    } // (
      flake-utils.lib.eachDefaultSystem
        (system:
          let
            pkgs = nixpkgs.legacyPackages.${system};
            nurPackages = nurPackageOverlay nurPackages pkgs;
          in
          rec {
            packages = flake-utils.lib.filterPackages system nurPackages;
          }
        )
    );
}
