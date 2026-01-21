{
  description = "rycee's NUR repository";

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
        system: nixpkgs.lib.filterAttrs (_: v: nixpkgs.lib.isDerivation v) self.legacyPackages.${system}
      );

      hmModules = {
        emacs-init.imports = [
          ./hm-modules/emacs-init-defaults.nix
          ./hm-modules/emacs-init.nix
        ];

        emacs-notmuch = ./hm-modules/emacs-notmuch.nix;
      };
    };
}
