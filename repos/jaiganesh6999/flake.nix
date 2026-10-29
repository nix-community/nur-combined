{
  description = "Lightweight website SEO audit tool and CLI by SEOWebChecker (https://seowebchecker.com/)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      packages = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        rec {
          seowebchecker = pkgs.callPackage ./nix/package.nix { };
          default = seowebchecker;
        }
      );

      apps = forAllSystems (system: {
        seowebchecker = {
          type = "app";
          program = "${self.packages.${system}.seowebchecker}/bin/seowebchecker";
        };
        default = self.apps.${system}.seowebchecker;
      });

      devShells = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            packages = [
              pkgs.nodejs
              self.packages.${system}.seowebchecker
            ];
          };
        }
      );

      nixosModules = {
        seowebchecker = import ./nix/module.nix;
        default = self.nixosModules.seowebchecker;
      };

      overlays = {
        default = final: prev: {
          seowebchecker = prev.callPackage ./nix/package.nix { };
        };
      };
    };
}
