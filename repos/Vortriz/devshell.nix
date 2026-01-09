{ inputs, ... }:
{
    imports = [ inputs.devshell.flakeModule ];

    perSystem =
        {
            config,
            lib,
            pkgs,
            ...
        }:
        {
            devshells.default =
                let
                    python = pkgs.python3.withPackages (_p: [
                        config.legacyPackages.nima
                    ]);
                in
                {
                    devshell.motd = "";

                    packages =
                        with pkgs;
                        [
                            nix-init
                            nix-prefetch-scripts
                            nix-prefetch-github

                            ruff
                        ]
                        ++ [ python ];

                    commands = [
                        {
                            name = "update";
                            help = "Update flake lock and update all packages using nix-update";
                            category = "[chore]";
                            command = ''
                                nix flake update
                                ${lib.getExe python} update.py pkgs
                                nix fmt
                            '';
                        }
                    ];
                };
        };
}
