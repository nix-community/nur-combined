{
  description = "Trev's NUR repository";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = {
    self,
    nixpkgs,
  }: let
    forAllSystems = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed;
  in {
    devShells = forAllSystems (
      system: let
        pkgs = nixpkgs.legacyPackages."${system}";
      in {
        default = pkgs.mkShell {
          packages = with pkgs; [
            git
            nix-update
            alejandra
            renovate
          ];
        };
      }
    );

    legacyPackages = forAllSystems (
      system:
        import ./default.nix {
          pkgs = nixpkgs.legacyPackages."${system}";
        }
    );

    packages = forAllSystems (
      system:
        nixpkgs.lib.filterAttrs (_: v: nixpkgs.lib.isDerivation v) self.legacyPackages.${system}
    );
  };
}
