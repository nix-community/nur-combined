{ config, lib, pkgs, nixosConfig, ... }:

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
        credential.helper = "store --file=${nixosConfig.sops.secrets.github_token.path}";
        init.defaultBranch = "main";
        merge.conflictstyle = "diff3";
        merge.ff = "only";
        pull.rebase = true;
        gpg.format = "ssh";
        gpg.ssh.allowedSignersFile = ''${pkgs.writeText "allowedSigners.txt"
          ''${config.programs.git.userEmail} ${nixosConfig.programs.ssh.knownHosts."local.local".publicKey}''}'';
        user.signingkey = "${config.home.homeDirectory}/.ssh/id_ed25519";
        commit.gpgsign = true;
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
