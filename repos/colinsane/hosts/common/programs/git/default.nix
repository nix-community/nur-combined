{ pkgs, ... }:

let
  gitIni = pkgs.formats.gitIni { };
in
{
  sane.programs.git = {
    packageUnwrapped = (pkgs.git.override {
      # build without gitweb support, as that installs to share/git,
      # which causes trouble trying to make the sandboxer
      perlSupport = false;
    }).overrideAttrs (upstream: {
      postInstall = upstream.postInstall + ''
        # git-jump is a symlink from bin/git-jump -> share/contrib/git-jump,
        # which causes trouble trying to make the sandboxer
        rm "$out/bin/git-jump"
      '';
    });
    suggestedPrograms = [
      "difftastic"
      "git-cinnabar"
      "git-lfs"  # LLMs like to use it
      "git-sane"
      "ssh"
    ];
    sandbox.net = "clearnet";
    sandbox.whitelistPwd = true;
    sandbox.autodetectCliPaths = "parent";  # autodetection is necessary for git-upload-pack; "parent" so that `git mv` works
    sandbox.extraHomePaths = [
      ".config/git"
      # even with `whitelistPwd`, git has to crawl *up* the path -- which isn't necessarily in the sandbox -- to locate parent .git files
      "dev"
      "knowledge"
      "nixos"
      "ref"
    ];
    sandbox.whitelistSsh = true;

    fs.".config/git/config".symlink.target = gitIni.generate "git-config" {
      include.path = [
        "config.prefs"
        "config.user"
      ];
    };

    fs.".config/git/config.prefs".symlink.target = gitIni.generate "git-config.prefs" {
      # top-level options documented:
      # - <https://git-scm.com/docs/git-config#_variables>
      alias.ad      = "add";
      alias.amend   = "commit --amend --no-edit";
      alias.br      = "branch";
      alias.co      = "checkout";
      alias.com     = "commit";
      alias.comit   = "commit";  # common typo
      alias.cp      = "cherry-pick";
      alias.dif     = "diff";  # common typo
      alias.difsum  = "diff --compact-summary";  #< show only the list of files which changed, not contents
      alias.pdiff   = "difftool";  # equivalent to `GIT_EXTERNAL_DIFF=difft git diff`
      alias.plog    = "!GIT_EXTERNAL_DIFF=difft DFT_IGNORE_COMMENTS=true git log --patch --ext-diff";
      # alias.pshow   = "!GIT_EXTERNAL_DIFF=difft DFT_IGNORE_COMMENTS=true git show --ext-diff";
      alias.pul     = "pull";  # common typo
      alias.rb      = "rebase";
      alias.reset-head = "reset --hard HEAD";
      alias.shoe    = "show";  # common typo
      alias.st      = "status";
      alias.stat    = "status";
      alias.uncommit = "reset HEAD~1";
      alias.unstage = "restore --staged :/";
      alias.work    = "!f() { git worktree add \"$1\" && cd \"$1\"; }; f";

      cinnabar.check = "no-version-check";  #< git-cinnabar: don't check for new release every invocation :(

      commit.verbose = true;  #< have `git commit` populate both status *and* diff to the editor

      diff.context = 8;  #< default 3 lines of context
      diff.interHunkContext = 8;  #< include up to this many extra lines to merge diff hunks
      diff.noPrefix = true;  #< don't show a/ or b/ prefixes in diffs
      # difftastic docs:
      # - <https://difftastic.wilfred.me.uk/git.html>
      diff.tool = "difftastic";
      difftool.prompt = false;
      "difftool \"difftastic\"".cmd = ''difft "$LOCAL" "$REMOTE"'';
      # now run `git difftool` to use difftastic git

      log.date = "iso";  #< render dates as YYYY-MM-DD HH:MM:SS +TZ
      log.follow = true;  #< make `git log PATH` behave like `git log --follow PATH`
      log.showSignature = false;

      merge.autoStash = true;
      merge.conflictStyle = "zdiff3";

      pull.autoStash = true;  # `git pull` on a dirty tree will stash, pull, then `stash apply`
      pull.rebase = true;  # make `git pull` behave like `git pull --rebase`.

      push.autoSetupRemote = true;
      push.default = "current";  #< `git push origin` will push the current branch to origin

      rebase.autoStash = true;  #< make `git rebase FOO` behave as `git stash && git rebase FOO && git stash apply`

      sendemail.annotate = "yes";
      sendemail.confirm = "always";

      status.short = true;  #< make `git statues` behave as `git status --short`

      stash.showPatch = true;
    };

    fs.".config/git/config.user".symlink.target = gitIni.generate "git-config.user" {
      user.name = "Colin";
      user.email = "colin@uninsane.org";
    };
  };
}
