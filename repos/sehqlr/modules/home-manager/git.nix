{ config, lib, pkgs, ... }: {
  programs.gh.enable = true;

  programs.git = {
    enable = true;
    aliases = {
      graph = "log --graph --oneline --decorate";
      staged = "diff --cached";
      wip =
        "for-each-ref --sort='authordate:iso8601' --format=' %(color:green)%(authordate:relative)%09%(color:white)%(refname:short)' refs/heads";
    };
    extraConfig.init.defaultBranch = "main";
    ignores = [ "result" ];
    userEmail = "hey@samhatfield.me";
    userName = "sehqlr";
  };
  programs.ssh = {
    enable = true;
    matchBlocks = {
      "bytes.zone" = {
        host = "git.bytes.zone";
        port = 2222;
        user = "git";
        identityFile = "~/.ssh/gitea";
      };
      "github" = {
        host = "github.com";
        user = "git";
        identityFile = "~/.ssh/github";
      };
      "gitlab" = {
        host = "gitlab.com";
        user = "git";
      };
      "sr.ht".host = "*sr.ht";
    };
  };
}
