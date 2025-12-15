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
                        command = ''
                            nix flake update
                            ${pkgs.lib.getExe pkgs.python3} update.py
                        '';
                    }
                ];
            };
        };
}
