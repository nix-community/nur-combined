{
  description = "Personal NUR repository of @sigprof";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";
    flake-utils.url = "github:numtide/flake-utils";

    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
    pre-commit-hooks.inputs.nixpkgs.follows = "nixpkgs";
    pre-commit-hooks.inputs.flake-utils.follows = "flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    pre-commit-hooks,
  }: let
    nurPackageOverlay = import ./overlay.nix;
  in
    {
      overlay = final: prev: nurPackageOverlay final prev;
    }
    // (
      flake-utils.lib.eachDefaultSystem (system: let
        pkgs = nixpkgs.legacyPackages.${system};
        nurPackages = nurPackageOverlay nurPackages pkgs;
      in rec {
        packages = flake-utils.lib.filterPackages system nurPackages;
      })
    )
    // (
      let
        checkedSystems = with flake-utils.lib.system; [
          x86_64-linux
          x86_64-darwin
          aarch64-linux
          aarch64-darwin
          # No `i686-linux` because `pre-commit-hooks` does not evaluate
        ];
      in
        flake-utils.lib.eachSystem checkedSystems (system: {
          checks = {
            pre-commit = pre-commit-hooks.lib.${system}.run {
              src = ./.;
              hooks = {
                alejandra.enable = true;
              };
            };
          };

          devShells.default = nixpkgs.legacyPackages.${system}.mkShell {
            inherit (self.checks.${system}.pre-commit) shellHook;
          };
        })
    );
}
