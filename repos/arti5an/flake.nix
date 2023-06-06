{
  description = "My personal NUR repository";
  inputs.nixpkgs.url = "nixpkgs";
  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in {
      packages = forAllSystems (system:
        import ./default.nix { pkgs = import nixpkgs { inherit system; }; });
    };
}
