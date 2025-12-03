{
  lib,
  config,
  vacuModules,
  ...
}:
{
  imports = [ vacuModules.git ];

  vacu.git.enable = lib.mkDefault config.vacu.isDev;
  vacu.git.config = {
    commit.verbose = true;
    init.defaultBranch = "master";
    pull.rebase = false;
    user.name = "Shelvacu";
    user.email = "git@shelvacu.com";
    author.name = "Shelvacu";
    author.email = "git@shelvacu.com";
    committer.name = "Shelvacu on ${config.vacu.hostName}";
    committer.email = "git@shelvacu.com";
    user.useConfigOnly = true;
    checkout.workers = 0;
    # "We *could* use atomic writes, but those are slowwwwww! Are you sure?????" - git, still living in the 90s
    # Yes git, I'm sure
    core.fsync = "all";
    diff.mnemonicPrefix = true;
    gc.reflogExpire = "never";
    gc.reflogExpireUnreachable = "never";

    url."https://github.com/".insteadOf = [
      "hgh:"
      "github-http:"
      "github-https:"
    ];
    url."git@github.com:".insteadOf = [
      "sgh:"
      "gh:"
      "github-ssh:"
    ];
    url."git@github.com:shelvacu/".insteadOf = [ "vgh:" ];
    url."https://gitlab.com/".insteadOf = [
      "hgl:"
      "gitlab-http:"
      "gitlab-https:"
    ];
    url."git@gitlab.com:".insteadOf = [
      "sgl:"
      "gl:"
      "gitlab-ssh:"
    ];
    url."git@gitlab.com:shelvacu/".insteadOf = [ "vgl:" ];
    url."https://git.uninsane.org/".insteadOf = [
      "hu:"
      "uninsane-http:"
      "uninsane-https:"
    ];
    url."git@git.uninsane.org:".insteadOf = [
      "u:"
      "su:"
      "uninsane-ssh"
    ];
    url."git@git.uninsane.org:shelvacu/".insteadOf = [ "vu:" ];
  };
}
