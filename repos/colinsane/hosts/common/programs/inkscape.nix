{ ... }:
{
  sane.programs.inkscape = {
    buildCost = 1;
    sandbox.whitelistWayland = true;
    sandbox.extraHomePaths = [
      "Pictures/albums"
      "Pictures/cat"
      "Pictures/from"
      "Pictures/Photos"
      "Pictures/Screenshots"
      "Pictures/servo-macros"
      "dev"
      "ref"
      "tmp"
    ];
    sandbox.autodetectCliPaths = true;
  };
}
