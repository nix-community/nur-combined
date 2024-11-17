{ lib, pkgs, ... }:

let
  # TODO: use formats.gitIni or lib.generators.toGitINI
  # - see: <repo:nixos/nixpkgs:pkgs/pkgs-lib/formats.nix>
  mkCfg = lib.generators.toINI { };
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
    sandbox.net = "clearnet";
    sandbox.whitelistPwd = true;
    sandbox.autodetectCliPaths = "parent";  # autodetection is necessary for git-upload-pack; "parent" so that `git mv` works
    sandbox.extraHomePaths = [
      # even with `whitelistPwd`, git has to crawl *up* the path -- which isn't necessarily in the sandbox -- to locate parent .git files
      "dev"
      "knowledge"
      "nixos"
      "ref"
      ".ssh/id_ed25519"  # for ssh-auth'd remotes
    ];
    fs.".config/git/config".symlink.text = mkCfg {
      # top-level options documented:
      # - <https://git-scm.com/docs/git-config#_variables>

      user.name = "Colin";
      user.email = "colin@uninsane.org";

      alias.amend   = "commit --amend --no-edit";
      alias.br      = "branch";
      alias.co      = "checkout";
      alias.com     = "commit";
      alias.cp      = "cherry-pick";
      alias.d       = "difftool";
      alias.dif     = "diff";  # common typo
      alias.difsum  = "diff --compact-summary";  #< show only the list of files which changed, not contents
      alias.rb      = "rebase";
      alias.reset-head = "reset --hard HEAD";
      alias.st      = "status";
      alias.stat    = "status";

      diff.noprefix = true;  #< don't show a/ or b/ prefixes in diffs
      # difftastic docs:
      # - <https://difftastic.wilfred.me.uk/git.html>
      diff.tool = "difftastic";
      difftool.prompt = false;
      "difftool \"difftastic\"".cmd = ''${lib.getExe pkgs.difftastic} "$LOCAL" "$REMOTE"'';
      # now run `git difftool` to use difftastic git

      # render dates as YYYY-MM-DD HH:MM:SS +TZ
      log.date = "iso";

      sendemail.annotate = "yes";
      sendemail.confirm = "always";

      stash.showPatch = true;
    };
  };
}
