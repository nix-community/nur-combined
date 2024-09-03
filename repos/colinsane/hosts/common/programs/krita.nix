{ ... }:
{
  sane.programs.krita = {
    buildCost = 1;
    sandbox.method = "bunpen";
    sandbox.whitelistWayland = true;
    sandbox.whitelistX = true;
    sandbox.autodetectCliPaths = "existing";
    sandbox.extraHomePaths = [
      "dev"
      "Pictures/albums"
      "Pictures/cat"
      "Pictures/from"
      "Pictures/Photos"
      "Pictures/Screenshots"
      "Pictures/servo-macros"
      "ref"
      "tmp"
    ];
  };
}
