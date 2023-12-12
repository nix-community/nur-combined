{
  description = "My personal NUR repository";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, flake-parts, ... }@inputs: flake-parts.lib.mkFlake { inherit inputs; } {
    systems = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "x86_64-darwin"
    ];

    perSystem = { self', lib, pkgs, ... }: {
      legacyPackages = import ./. { inherit pkgs; };
      packages = nixpkgs.lib.filterAttrs (_: nixpkgs.lib.isDerivation) self'.legacyPackages;

      devShells.default = pkgs.mkShell {
        packages = with pkgs; [
          just
        ];
      };

      apps.update = {
        type = "app";
        program = lib.getExe (pkgs.writeShellApplication {
          name = "update";
          text = ''
            nix-shell "${nixpkgs.outPath}/maintainers/scripts/update.nix" \
              --arg include-overlays "[(import ./overlay.nix)]" \
              --arg predicate '(
                let prefix = builtins.toPath ./packages; prefixLen = builtins.stringLength prefix;
                in (_: p: p.meta?position && (builtins.substring 0 prefixLen p.meta.position) == prefix)
              )'
          '';
        });
      };

      formatter = pkgs.nixpkgs-fmt;
    };
  };

  nixConfig = {
    extra-substituters = [
      "https://federicoschonborn.cachix.org"
    ];
    extra-trusted-public-keys = [
      "federicoschonborn.cachix.org-1:tqctt7S1zZuwKcakzMxeATNq+dhmh2v6cq+oBf4hgIU="
    ];
  };
}
