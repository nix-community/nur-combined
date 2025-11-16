{
  description = "Ev357 personal NUR repository";

  nixConfig = {
    extra-substituters = [
      "https://ev357.cachix.org"
    ];
    extra-trusted-public-keys = [
      "ev357.cachix.org-1:bI65rULXWJ8IMM+tosc/Z+9W53nL6uj4+5FLXX6BN3Q="
    ];
  };

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = {
    self,
    nixpkgs,
  }: let
    forAllSystems = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed;
  in {
    legacyPackages = forAllSystems (system:
      import ./default.nix {
        pkgs = import nixpkgs {inherit system;};
      });
    packages = forAllSystems (system: nixpkgs.lib.filterAttrs (_: v: nixpkgs.lib.isDerivation v) self.legacyPackages.${system});

    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);
  };
}
