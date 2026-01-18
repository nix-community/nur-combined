{ config, pkgs, nixosConfig, ... }:
let
  workDir = "${config.home.homeDirectory}/repos/work";
in
{
  sops.secrets.github_token = {
    path = "${config.xdg.configHome}/git/credentials";
  };
  sops.secrets.gitconfig = {
    format = "binary";
    sopsFile = ../../secrets/gitconfig;
    path = "${workDir}/.gitconfig";
  };

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "slaier";
        email = "slaier@users.noreply.github.com";
      };
      credential.helper = "store";
      init.defaultBranch = "main";
      merge.conflictstyle = "diff3";
      merge.ff = "only";
      pull.rebase = true;
      rebase.autoSquash = true;
      rebase.autoStash = true;
      gpg.format = "ssh";
      gpg.ssh.allowedSignersFile = ''${pkgs.writeText "allowedSigners.txt"
          ''${config.programs.git.settings.user.email} ${nixosConfig.programs.ssh.knownHosts."local.lan".publicKey}''}'';
      user.signingkey = "${config.home.homeDirectory}/.ssh/id_ed25519";
      commit.gpgsign = true;
      aliases = {
        lg = "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
      };
    };

    includes = [
      {
        path = config.sops.secrets.gitconfig.path;
        condition = "gitdir:${workDir}/";
      }
    ];

    ignores = [
      ".cache"
      ".direnv"
    ];
  };

  programs.diff-so-fancy.enable = true;
}
