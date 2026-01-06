{
  description = "My personal NUR repository";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    ag = {
      url = "github:srcres258/ag";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  
  outputs = {
    self,
    nixpkgs,
    ag
  }: let
    forAllSystems = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed;
  in {
    legacyPackages = forAllSystems (system: import ./default.nix {
      pkgs = import nixpkgs { inherit system; };
    });
    packages = forAllSystems (system: (nixpkgs.lib.filterAttrs (
      _: v: nixpkgs.lib.isDerivation v
    ) self.legacyPackages.${system}) // { ag = ag.packages.${system}.default; });

    overlays.default = final: prev: {
        nur.repos.srcres258 = self.packages.x86_64-linux;
    };
  };
}
