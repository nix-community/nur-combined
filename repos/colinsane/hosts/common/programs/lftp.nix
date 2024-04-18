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
  };
}
