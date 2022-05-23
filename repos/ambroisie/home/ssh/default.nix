{ config, lib, ... }:
let
  cfg = config.my.home.ssh;
in
{
  options.my.home.ssh = with lib.my; {
    enable = mkDisableOption "ssh configuration";
  };

  config.programs.ssh = lib.mkIf cfg.enable {
    enable = true;

    matchBlocks = {
      "github.com" = {
        hostname = "github.com";
        identityFile = "~/.ssh/shared_rsa";
        user = "git";
      };

      "gitlab.com" = {
        hostname = "gitlab.com";
        identityFile = "~/.ssh/shared_rsa";
        user = "git";
      };

      "git.sr.ht" = {
        hostname = "git.sr.ht";
        identityFile = "~/.ssh/shared_rsa";
        user = "git";
      };

      "gitea.belanyi.fr" = {
        hostname = "gitea.belanyi.fr";
        identityFile = "~/.ssh/shared_rsa";
        user = "git";
      };

      porthos = {
        hostname = "91.121.177.163";
        identityFile = "~/.ssh/shared_rsa";
        user = "ambroisie";
      };

      work = {
        hostname = "workspaces.dgexsol.fr";
        identityFile = "~/.ssh/shared_rsa";
        user = "bruno_belanyi";
      };
    };

    extraConfig = ''
      AddKeysToAgent yes
    '';
  };
}
