{
    description = "My personal NUR repository";

    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
        systems.url = "github:nix-systems/default-linux";
        flake-utils = {
            url = "github:numtide/flake-utils";
            inputs.systems.follows = "systems";
        };
        devshell = {
            url = "github:numtide/devshell";
            inputs.nixpkgs.follows = "nixpkgs";
        };
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
        flake-utils,
        devshell,
        pre-commit-hooks,
        treefmt-nix,
        ...
    }:
        flake-utils.lib.eachDefaultSystem (system: let
            inherit (nixpkgs) lib;

            pkgs = import nixpkgs {
                inherit system;
                overlays = [devshell.overlays.default];
            };

            treefmtEval = treefmt-nix.lib.evalModule pkgs ./treefmt.nix;
        in {
            formatter = treefmtEval.config.build.wrapper;

            checks = {
                pre-commit-check = pre-commit-hooks.lib.${system}.run {
                    src = ./.;
                    inherit ((import ./treefmt.nix).settings.global) excludes;
                    hooks = {
                        treefmt = {
                            enable = true;
                            package = self.formatter.${system};
                        };
                    };
                };
            };

            packages = import ./default.nix {inherit pkgs;};

            devShells.default = let
                python-pkg = pkgs.python313;
            in
                pkgs.devshell.mkShell
                {
                    devshell.motd = "";

                    packages = with pkgs;
                        [
                            nix-init
                            nvfetcher
                            uv
                            ruff
                        ]
                        ++ [python-pkg];

                    env = [
                        {
                            # Prevent uv from managing Python downloads
                            name = "UV_PYTHON_DOWNLOADS";
                            value = "never";
                        }
                        {
                            # Force uv to use nixpkgs Python interpreter
                            name = "UV_PYTHON";
                            value = python-pkg.interpreter;
                        }
                        {
                            # Python libraries often load native shared objects using dlopen(3).
                            # Setting LD_LIBRARY_PATH makes the dynamic library loader aware of libraries without using RPATH for lookup.
                            # We use manylinux2014 which is compatible with 3.7.8+, 3.8.4+, 3.9.0+
                            name = "LD_LIBRARY_PATH";
                            prefix = lib.makeLibraryPath pkgs.pythonManylinuxPackages.manylinux2014;
                        }
                    ];

                    devshell.startup.default.text = "unset PYTHONPATH";
                };
        });
}
