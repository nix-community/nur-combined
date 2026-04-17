{ self, ... }:
{
  flake.modules.nixos.dev =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      imports = with self.modules.nixos; [
        ssh
        git
        dev-pkgs
      ];
      programs = {
        bash.interactiveShellInit = ''
          eval "$(${lib.getExe pkgs.atuin} init bash)"
        '';
        fish.interactiveShellInit = ''
          ${lib.getExe pkgs.atuin} init fish | source
          ${lib.getExe pkgs.zoxide} init fish | source
        '';
        nh = {
          enable = true;
          # clean.enable = true;
          # clean.extraArgs = "--keep-since 4d --keep 7";
          flake = "/home/${config.identity.user}/Src/nixos";
        };
        direnv = {
          enable = true;
          package = pkgs.direnv;
          silent = false;
          loadInNixShell = true;
          direnvrcExtra = "";
          nix-direnv = {
            enable = true;
            package = pkgs.nix-direnv;
          };
        };
      };

    };

}
