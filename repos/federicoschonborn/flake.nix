{
  description = "My personal NUR repository";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    systems.url = "github:nix-systems/default";
  };

  outputs = { self, nixpkgs, systems, ... }:
    let
      inherit (nixpkgs) lib;

      eachSystem = f: lib.genAttrs (import systems) (system: f nixpkgs.legacyPackages.${system});
    in
    {
      legacyPackages = eachSystem (pkgs: import ./. { inherit pkgs; });
      packages = eachSystem (pkgs: lib.filterAttrs (_: lib.isDerivation) self.legacyPackages.${pkgs.system});
      formatter = eachSystem (pkgs: pkgs.nixpkgs-fmt);
    };
}
