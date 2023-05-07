{ config, lib, ... }:

with lib;
let
  cfg = config.slaier.git;
in
{
  options.slaier.git = {
    userName = mkOption {
      type = types.str;
      default = "Slaier";
      description = "git user name";
    };
    userEmail = mkOption {
      type = types.str;
      default = "slaier@users.noreply.github.com";
      description = "git user email";
    };
  };

  config = {
    programs.git = {
      inherit (cfg) userName userEmail;

      enable = true;
      diff-so-fancy = {
        enable = true;
      };
      extraConfig = {
        core.editor = "vim";
        credential.helper = "store";
        init.defaultBranch = "main";
        merge.conflictstyle = "diff3";
        merge.ff = "only";
        pull.rebase = true;
      };

      ignores = [
        ".ccls-cache/"
      ];

      aliases = {
        d = "diff";
        dc = "diff --cached";
        ds = "diff --staged";
        r = "restore";
        rs = "restore --staged";
        st = "status -sb";
        lg = "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
      };
    };
  };
}
