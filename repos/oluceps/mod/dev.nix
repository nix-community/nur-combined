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
        # git-absorb
      ];
      programs = {
        atuin = {
          enable = true;
          flags = [ "--disable-up-arrow" ];
          settings = {
            auto_sync = true;
            dialect = "us";
            filter_mode = "global";
            filter_mode_shell_up_key_binding = "directory";
            key_path = config.vaultix.secrets.atuin_key.path;
            sync_address = "https://api.atuin.nyaw.xyz";
            sync_frequency = "5m";
            search_mode = "fuzzy";
          };
        };

        fish.interactiveShellInit = ''
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
