{
    description = "My personal NUR repository";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
        pre-commit-hooks = {
            url = "github:cachix/git-hooks.nix";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        treefmt-nix = {
            url = "github:numtide/treefmt-nix";
            inputs.nixpkgs.follows = "nixpkgs";
        };
    };

    outputs = {
        self,
        nixpkgs,
        ...
    } @ inputs: let
        forAllSystems = nixpkgs.lib.genAttrs ["x86_64-linux" "aarch64-linux"];
        forAllPkgs = f: forAllSystems (system: f nixpkgs.legacyPackages.${system});
        treefmtEval = forAllPkgs (pkgs: inputs.treefmt-nix.lib.evalModule pkgs ./treefmt.nix);
    in {
        legacyPackages = forAllSystems (system:
            import ./default.nix {
                pkgs = import nixpkgs {inherit system;};
            });

        formatter = forAllPkgs (pkgs: treefmtEval.${pkgs.stdenv.hostPlatform.system}.config.build.wrapper);

        checks = forAllSystems (system: {
            pre-commit-check = inputs.pre-commit-hooks.lib.${system}.run {
                src = ./.;
                hooks = {
                    flake-checker = {
                        enable = true;
                        after = ["treefmt-nix"];
                    };
                    treefmt-nix = {
                        enable = true;
                        entry = "${treefmtEval.${system}.config.build.wrapper}/bin/treefmt";
                        pass_filenames = false;
                    };
                };
            };
        });

        packages = forAllSystems (system: nixpkgs.lib.filterAttrs (_: v: nixpkgs.lib.isDerivation v) self.legacyPackages.${system});

        devShells = forAllSystems (system: let
            pkgs = nixpkgs.legacyPackages.${system};
        in {
            default = pkgs.mkShell {
                inherit (self.checks.${system}.pre-commit-check) shellHook;

                buildInputs = [
                    self.checks.${system}.pre-commit-check.enabledPackages
                    treefmtEval.${system}.config.build.wrapper
                ];

                packages = with pkgs; [
                    just
                    nix-init
                    nvfetcher
                ];
            };
        });
    };
}
