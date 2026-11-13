{
  description = "Personal NUR packages";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  outputs =
    { self, nixpkgs }:
    let
      forAllSystems = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed;
    in
    {
      legacyPackages = forAllSystems (
        system:
        import ./default.nix {
          pkgs = import nixpkgs { inherit system; };
        }
      );
      packages = forAllSystems (
        system:
        nixpkgs.lib.filterAttrs (
          _: v: nixpkgs.lib.isDerivation v && nixpkgs.lib.meta.availableOn { inherit system; } v
        ) self.legacyPackages.${system}
      );
      devShells = forAllSystems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
          updatePackages = pkgs.writeShellApplication {
            name = "update-packages";
            runtimeInputs = with pkgs; [
              bash
              gh
              git
              jq
              nix
            ];
            text = ''
              repo_root=$(git rev-parse --show-toplevel)
              exec bash "$repo_root/update.sh" "$@"
            '';
          };
        in
        {
          default = pkgs.mkShell {
            packages = [ updatePackages ];
          };
        }
      );
      overlays = import ./overlays;
      nixosModules = import ./nixos-modules;
    };
}
