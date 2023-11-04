{
  description = "My personal NUR repository";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.url = "github:nix-systems/default";
    };
  };

  outputs = { self, nixpkgs, flake-utils, ... }: flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      legacyPackages = import ./. { inherit pkgs; };
      packages = nixpkgs.lib.filterAttrs (_: nixpkgs.lib.isDerivation) self.legacyPackages.${system};
      devShells.default = pkgs.mkShell {
        packages = with pkgs; [
          just
          nix-output-monitor
        ];
      };
      apps.update = flake-utils.lib.mkApp {
        name = "update";
        drv = pkgs.writeShellApplication {
          name = "update";
          text = ''
            nix-shell "${nixpkgs.outPath}/maintainers/scripts/update.nix" \
              --arg include-overlays "[(import ./overlay.nix)]" \
              --arg predicate '(
                let prefix = builtins.toPath ./packages; prefixLen = builtins.stringLength prefix;
                in (_: p: (builtins.substring 0 prefixLen p.meta.position) == prefix)
              )'
          '';
        };
      };
      formatter = pkgs.nixpkgs-fmt;
    });

  nixConfig = {
    extra-substituters = [
      "https://federicoschonborn.cachix.org"
    ];
    extra-trusted-public-keys = [
      "federicoschonborn.cachix.org-1:tqctt7S1zZuwKcakzMxeATNq+dhmh2v6cq+oBf4hgIU="
    ];
  };
}
