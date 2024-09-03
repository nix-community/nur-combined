{ ... }:
{
  sane.programs.inkscape = {
    buildCost = 1;
    sandbox.method = "bunpen";
    sandbox.whitelistWayland = true;
    sandbox.extraHomePaths = [
      ".config/dconf"  #< else opening images fails
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
