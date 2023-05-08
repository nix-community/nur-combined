{ lib, pkgs, ... }:

let
  mkCfg = lib.generators.toINI { };
in
{
  sane.programs.git.fs.".config/git/config".symlink.text = mkCfg {
    user.name = "Colin";
    user.email = "colin@uninsane.org";
    alias.co = "checkout";
    # difftastic docs:
    # - <https://difftastic.wilfred.me.uk/git.html>
    diff.tool = "difftastic";
    difftool.prompt = false;
    "difftool \"difftastic\"".cmd = ''${pkgs.difftastic}/bin/difft "$LOCAL" "$REMOTE"'';
    # now run `git difftool` to use difftastic git
  };
}
