{ inputs, ... }:
{
    imports = [ inputs.devshell.flakeModule ];

    perSystem =
        { pkgs, ... }:
        {
            devshells.default = {
                devshell.motd = "";

                packages = with pkgs; [
                    nix-init
                    nix-update
                ];

                commands = [
                    {
                        name = "update";
                        help = "Update flake lock and update all packages using nix-update";
                        category = "[chore]";
                        package = pkgs.python3;
                        command = ''
                            nix flake update
                            python update.py
                        '';
                    }
                ];
            };
        };
}
