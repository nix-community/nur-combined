{ ... }:
{
  sane.programs.tuba = {
    buildCost = 1;

    sandbox.net = "clearnet";
    sandbox.whitelistAudio = true;
    sandbox.whitelistDbus = [ "user" ];  # notifications
    sandbox.whitelistWayland = true;
    sandbox.extraHomePaths = [
      "Music"
      "Pictures/albums"
      "Pictures/cat"
      "Pictures/from"
      "Pictures/Photos"
      "Pictures/Screenshots"
      "Pictures/servo-macros"
      "Videos/local"
      "Videos/servo"
      "tmp"
    ];

    suggestedPrograms = [ "gnome-keyring" ];
  };
}
