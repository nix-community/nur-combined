{ ... }:
{
  sane.programs.lftp = {
    sandbox.method = "bwrap";
    sandbox.net = "all";
    sandbox.extraPaths = [
      "Music"
      "Videos/local"
      "Videos/servo"
      "tmp"
    ];
    sandbox.whitelistPwd = true;  #< it's very common to upload/DL to/from the current folder
  };
}
