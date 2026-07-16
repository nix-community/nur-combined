{ pkgs, ... }:
{
  sane.programs.openscad = {
    # packageUnwrapped = pkgs.openscad-unstable;  #< XXX(2026-06-05): openscad fails build
    buildCost = 1;

    # if pointed to a file, allow the dir; if opening a dir (is that possible?) allow that dir.
    sandbox.autodetectCliPaths = "existingDirOrParent";
    sandbox.whitelistWayland = true;
    # allow to create or reference files under the current directory.
    sandbox.whitelistPwd = true;
    sandbox.extraHomePaths = [
      "tmp"
    ];
  };
}
