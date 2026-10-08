{
  lib,
  config,
  vacuModules,
  ...
}:
{
  imports = [ vacuModules.git ];

  vacu.git.enable = lib.mkDefault config.vacu.isDev;
  vacu.git.lfs.enable = lib.mkDefault (!config.vacu.isMinimal);
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
    stash.showIncludeUntracked = true; # when `show`ing a stash, show *all* of it, even the untracked files
  };
}
