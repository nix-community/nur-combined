{
  description = "Myuu's NUR repository";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, treefmt-nix, }:
    let forAllSystems = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed;
    in {
      legacyPackages = forAllSystems (system:
        import ./default.nix { pkgs = import nixpkgs { inherit system; }; });
      packages = forAllSystems (system:
        nixpkgs.lib.filterAttrs (_: v: nixpkgs.lib.isDerivation v)
        self.legacyPackages.${system});

      overlays.default = import ./overlay.nix;
      formatter = forAllSystems (system:
        let pkgs = import nixpkgs { inherit system; };
        in treefmt-nix.lib.mkWrapper pkgs {
          projectRootFile = "flake.nix";
          programs.nixfmt.enable = true;
        });
    };
}
