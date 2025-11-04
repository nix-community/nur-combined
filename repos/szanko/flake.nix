{
  description = "SZanko's NUR repository";
  inputs = {
    nixpkgs-2311.url = "github:nixos/nixpkgs/nixos-23.11";
    nixpkgs-2411.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-2505.url = "github:nixos/nixpkgs/nixos-25.05"; 
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    #nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05"; # Currently not a maintainer in 25.05 but in 25.11
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };
  outputs = { self, nixpkgs, nixpkgs-unstable, nixpkgs-2311, nixpkgs-2411, nixpkgs-2505 }:
    let
      forAllSystems = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed;
    in
    {
      legacyPackages = forAllSystems (system: 
        let
          pkgs = import nixpkgs {
            inherit system;
            config = {
              allowUnfree = true;
              allowUnsupportedSystem = true;
            };
          };
          pkgsUnstable = import nixpkgs-unstable { inherit system; };
          pkgs2311 = import nixpkgs-2311 { inherit system; };
          pkgs2411 = import nixpkgs-2411 { inherit system; };
          pkgs2505 = import nixpkgs-2505 { inherit system; };
        in
          import ./default.nix {
            inherit pkgs;
            pkgs2311 = pkgs2311;
            pkgs2411 = pkgs2411;
            pkgs2505 = pkgs2505;
            pkgsUnstable = pkgsUnstable;
      });
      packages = forAllSystems (system: nixpkgs.lib.filterAttrs (_: v: nixpkgs.lib.isDerivation v) self.legacyPackages.${system});
      checks = forAllSystems (system: self.packages.${system});
    };
}
