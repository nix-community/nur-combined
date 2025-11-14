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
        treefmt-nix = {
            url = "github:numtide/treefmt-nix";
            inputs.nixpkgs.follows = "nixpkgs";
        };
    };

    outputs =
        {
            nixpkgs,
            flake-utils,
            devshell,
            treefmt-nix,
            ...
        }:
        flake-utils.lib.eachDefaultSystem (
            system:
            let
                inherit (nixpkgs) lib;

                pkgs = import nixpkgs {
                    inherit system;
                    overlays = [ devshell.overlays.default ];
                    config.allowUnfree = true;
                };

                treefmtEval = treefmt-nix.lib.evalModule pkgs ./treefmt.nix;

                pinned-packages = [
                    "libfprint-focaltech-2808-a658-alt"
                ];
            in
            {
                formatter = treefmtEval.config.build.wrapper;

                packages = import ./default.nix { inherit pkgs; };

                devShells.default = pkgs.devshell.mkShell {
                    devshell.motd = "";

                    packages = with pkgs; [
                        nix-init
                        jq
                        nix-update
                    ];

                    env = [
                        {
                            name = "PACKAGES";
                            eval = "$(nix flake show --all-systems --json | jq -r '[.packages[] | keys[]] | sort | unique |  join(\",\")')";
                        }
                        {
                            name = "BLACKLIST";
                            value = lib.strings.join "," pinned-packages;
                        }
                    ];

                    commands = [
                        {
                            name = "update";
                            help = "Update flake lock and update all packages using nix-update";
                            category = "[chore]";
                            command = ''
                                nix flake update
                                bash nix-update.sh
                            '';
                        }
                    ];
                };
            }
        );
}
