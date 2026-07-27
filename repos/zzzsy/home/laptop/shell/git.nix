{ pkgs, ... }:
{
  programs.git = {
    enable = true;
    settings.user.email = "me@zzzsy.top";
    settings.user.name = "Mathias Zhang";
    settings.alias = {
      tree = "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(bold yellow)%d%C(reset)%n''          %C(white)%s%C(reset) %C(dim white)- %an%C(reset)' --all";
    };
    signing = {
      signByDefault = true;
      key = "~/.ssh/id_ed25519";
    };
    settings = {
      gpg = {
        format = "ssh";
        ssh.allowedSignersFile = toString (pkgs.writeText "allowed_signers" "");
      };
      merge.conflictStyle = "zdiff3";
      diff.algorithm = "histogram";
      diff.submodule = "log";
      pull.rebase = true;
      init.defaultBranch = "main";
      fetch.prune = true;
      rerere.enable = true;
    };
  };
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      decorations = {
        commit-decoration-style = "bold yellow box ul";
        file-decoration-style = "none";
        file-style = "bold yellow ul";
      };
      side-by-side = true;
      features = "decorations";
    };
  };
}
