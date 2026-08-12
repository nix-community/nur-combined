{
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-20.09;
  };
  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" ];

      # Function to generate a set based on supported systems
      forAllSystems = f:
        nixpkgs.lib.genAttrs supportedSystems (system: f system);

      nixpkgsFor = forAllSystems (system: import nixpkgs {
        inherit system;
        overlays = [ ];
      });

    in {
      packages = forAllSystems (system:
        import ./default.nix {
          pkgs = nixpkgsFor.${system};
        });
    };
}
