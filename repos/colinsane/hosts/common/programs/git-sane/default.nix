{ ...}:
{
  sane.programs.git-sane = {
    suggestedPrograms = [
      "delta"
      "difftastic"
    ];
    # it calls back into `git`, so we need access to `.git` and the rest.
    # copied from `sane.programs.git.sandbox`
    sandbox.whitelistPwd = true;
    sandbox.extraHomePaths = [
      ".config/git"
      # even with `whitelistPwd`, git has to crawl *up* the path -- which isn't necessarily in the sandbox -- to locate parent .git files
      "dev"
      "knowledge"
      "nixos"
      "ref"
    ];
  };
}
