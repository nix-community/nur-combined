{
  description = "My personal NUR repository";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  outputs =
    { self, nixpkgs }:
    let
      forAllSystems = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed;
      pkgsFor = system: import nixpkgs { inherit system; };
    in
    {
      legacyPackages = forAllSystems (
        system:
        import ./default.nix {
          pkgs = pkgsFor system;
        }
      );
      packages = forAllSystems (
        system:
        let
          pkgs = pkgsFor system;
        in
        nixpkgs.lib.filterAttrs (_: v: nixpkgs.lib.isDerivation v) self.legacyPackages.${system}
        // nixpkgs.lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
          attic-cache-image = pkgs.callPackage ./deploy/attic/image.nix { };
        }
      );
      apps = forAllSystems (
        system:
        let
          pkgs = pkgsFor system;
          update =
            pkgs.runCommand "nur-packages-update"
              {
                nativeBuildInputs = [
                  pkgs.amber-lang
                  pkgs.makeWrapper
                ];
              }
              ''
                mkdir -p "$out/bin"
                amber build ${./maintainers/update.ab} "$out/bin/nur-packages-update"
                wrapProgram "$out/bin/nur-packages-update" \
                  --prefix PATH : ${
                    pkgs.lib.makeBinPath [
                      pkgs.git
                      pkgs.nix
                      pkgs.nix-update
                    ]
                  }
              '';
        in
        {
          update = {
            type = "app";
            program = "${update}/bin/nur-packages-update";
            meta.description = "Update pinned NUR packages with nix-update";
          };
        }
      );
      nixosModules = import ./nixos-modules;
      # homeModules = import ./home-modules;
      # darwinModules = import ./darwin-modules;
      # flakeModules = import ./flake-modules;
    };
}
