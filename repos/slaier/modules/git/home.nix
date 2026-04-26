{ config, pkgs, nixosConfig, ... }:
{
  sops.secrets.github_token = {
    path = "${config.xdg.configHome}/git/credentials";
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
      alias = {
        lg = "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
      };
    };

    ignores = [
      ".cache"
      ".direnv"
    ];
  };

  programs.diff-so-fancy.enable = true;
}
