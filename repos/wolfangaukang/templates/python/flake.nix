{
  description = "Python project";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
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
      pkgsFor = nixpkgs.lib.genAttrs systems (system: import nixpkgs {
        overlays = [ poetry2nix.overlays.default ];
        inherit system;
      });

    in
    {
      #packages = forEachSystem (system: {
        #default = pkgsFor.${system}.callPackage ./package.nix { };
      #});
      # apps = forEachSystem (system: {
      #   default = { type = "app"; program = pkgsFor.${system}.lib.getExe self.outputs.packages.${system}.default; };
      # });
      formatter = forEachSystem (system: pkgsFor.${system}.nixpkgs-fmt);
      devShells = forEachSystem (system:
        let
          pkgs = pkgsFor.${system};
          inherit (pkgs) mkShell dprint gnumake marksman nil poetry taplo;
          inherit (pkgs.python3Packages) python-lsp-server;
          devEnv = pkgs.poetry2nix.mkPoetryEnv { projectDir = (pkgsFor.${system}.lib.cleanSource ./.); };

        in
        {
          default = mkShell {
            buildInputs = [ devEnv dprint gnumake marksman nil poetry python-lsp-server taplo ];
            PYTHON_KEYRING_BACKEND = "keyring.backends.null.Keyring";
          };
        });
    };
}
