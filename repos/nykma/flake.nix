{
  description = "Nyk Ma's personal NUR repository";
  inputs = {
    nixpkgs-protobuf320.url = "github:NixOS/nixpkgs/656b40c807e4c4965198a68d1f784492397fef6c";
    nixpkgs-protobuf293.url = "github:NixOS/nixpkgs/3a7baab73a629847afbcca8a52765c0b5fec49ae";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, nixpkgs-protobuf320, nixpkgs-protobuf293, rust-overlay }:
    let
      systems = [
        "x86_64-linux"
        "i686-linux"
        "x86_64-darwin"
        "aarch64-darwin"
        "aarch64-linux"
        "armv6l-linux"
        "armv7l-linux"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
      nixpkgsFor = forAllSystems (system: import nixpkgs {
        inherit system;
        overlays = [ rust-overlay.overlays.default ];
      });
      nixpkgs-protobuf320For = forAllSystems (system: import nixpkgs-protobuf320 {
        inherit system;
      });
      nixpkgs-protobuf293For = forAllSystems (system: import nixpkgs-protobuf293 {
        inherit system;
      });
    in
    {
      legacyPackages = forAllSystems (system:
        let
          pkgs = nixpkgsFor.${system};
          pkgs-protobuf320 = nixpkgs-protobuf320For.${system};
          pkgs-protobuf293 = nixpkgs-protobuf293For.${system};
        in
        import ./default.nix {
          inherit pkgs pkgs-protobuf320 pkgs-protobuf293;
        });
      packages = forAllSystems (system:
        let
          pkgs = nixpkgsFor.${system};
        in
        pkgs.lib.filterAttrs (_: v: pkgs.lib.isDerivation v) self.legacyPackages.${system});
      devShells = forAllSystems (system:
        let
          pkgs = nixpkgsFor.${system};
        in {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [
              nixd
              nix-update
              just
              cachix
            ];
          };
        }
      );
    };
}
