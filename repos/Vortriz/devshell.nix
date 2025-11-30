{ inputs, ... }:
{
    imports = [ inputs.devshell.flakeModule ];

    perSystem =
        { lib, pkgs, ... }:
        let
            pinned-packages = [
                "fprintd"
                "libfprint-focaltech-2808-a658-alt"
                "nixos-boot-plymouth-theme"
            ];
        in
        {
            devshells.default = {
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
                    {
                        name = "update-package";
                        help = "Update specified packages using nix-update";
                        category = "[chore]";
                        command = ''
                            nix-update --version=branch $1
                        '';
                    }
                ];
            };
        };
}
