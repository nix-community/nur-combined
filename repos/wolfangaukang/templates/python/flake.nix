{
  description = "Template for Python projects that uses Poetry";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    poetry2nix = {
      url = "github:nix-community/poetry2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs = { nixpkgs, poetry2nix, ... }:
    let
      systems = nixpkgs.lib.systems.flakeExposed;
      forEachSystem = nixpkgs.lib.genAttrs systems;
      pkgsFor = forEachSystem (system: import nixpkgs {
        overlays = [ poetry2nix.overlays.default ];
        inherit system;
      });
      projectDir = nixpkgs.lib.cleanSource ./.;

    in
    {
      devShells = forEachSystem (system:
        let
          pkgs = pkgsFor.${system};
          inherit (pkgs) mkShell poetry;
          inherit (pkgs.python3Packages) python-lsp-server;
          devEnv = pkgs.poetry2nix.mkPoetryEnv { inherit projectDir; };

        in
        {
          default = mkShell { buildInputs = [ devEnv poetry python-lsp-server ]; };
        });
      formatter = forEachSystem (system: pkgsFor.${system}.nixpkgs-fmt);
    };
}
