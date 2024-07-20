{ pkgs, ... }:
{
  sane.programs.kdenlive = {
    buildCost = 1;

    sandbox.method = "bwrap";
    sandbox.extraHomePaths = [
      "Music"
      "Pictures/from"  # e.g. Videos taken from my phone
      "Pictures/servo-macros"
      "Videos/local"
      "Videos/servo"
      "tmp"
    ];
    sandbox.whitelistAudio = true;
    sandbox.whitelistDbus = [ "user" ];  # notifications
    sandbox.whitelistDri = true;
    sandbox.whitelistWayland = true;
  };
}
