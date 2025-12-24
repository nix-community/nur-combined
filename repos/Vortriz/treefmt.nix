{ inputs, ... }:
{
    imports = [
        inputs.treefmt-nix.flakeModule
    ];

    perSystem = {
        treefmt.config = {
            # Used to find the project root
            projectRootFile = "flake.nix";

            programs = {
                deadnix.enable = true;
                statix.enable = true;
                nixfmt.enable = true;

                ruff-format.enable = true;
                ruff-check.enable = true;

                prettier.enable = true;
            };

            settings = {
                formatter = {
                    deadnix.priority = 1;
                    statix.priority = 2;
                    nixfmt = {
                        options = [
                            "--indent=4"
                        ];
                        priority = 3;
                    };

                    ruff-check.priority = 1;
                    ruff-format.priority = 2;

                    prettier.options = [
                        "--tab-width"
                        "4"
                    ];
                };
            };
        };
    };
}
