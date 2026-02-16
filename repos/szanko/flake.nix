{
  description = "SZanko's NUR repository";
  inputs = {
    nixpkgs-2311.url = "github:nixos/nixpkgs/nixos-23.11";
    nixpkgs-2411.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-2505.url = "github:nixos/nixpkgs/nixos-25.05"; 
    nixpkgs-2511.url = "github:nixos/nixpkgs/nixos-25.11"; 
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    #nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05"; # Currently not a maintainer in 25.05 but in 25.11
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    pnpm2nix-nzbr = {
      url = "github:nzbr/pnpm2nix-nzbr";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    clj-nix.url = "github:jlesquembre/clj-nix";
  };
  outputs = { self, nixpkgs, nixpkgs-unstable, nixpkgs-2311, nixpkgs-2411, nixpkgs-2505, nixpkgs-2511, pnpm2nix-nzbr, clj-nix, ... }:
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
          pkgs2511 = import nixpkgs-2511 { inherit system; };
        in
          import ./default.nix {
            inherit pkgs pkgs2311 pkgs2411 pkgs2505 pkgs2511 pkgsUnstable;
            cljNix = clj-nix;
      });
      packages = forAllSystems (system: nixpkgs.lib.filterAttrs (_: v: nixpkgs.lib.isDerivation v) self.legacyPackages.${system});
      checks = forAllSystems (system: self.packages.${system});
      devShells = forAllSystems (system:
        let
          pkgs = import nixpkgs-unstable {
            inherit system;
            config = {
              allowUnfree = true;
              allowUnsupportedSystem = true;
            };
          };
        in
        {
          default = pkgs.mkShell {
            name = "nur-packages-devshell";

            packages = with pkgs; [
              git
              nix
              nixfmt
              nil          
              statix
              deadnix
              direnv
              nix-init

              just
              jq
            ];

          };
        }
      );
    };
}
