{ ... }:
{
  sane.programs.tuba = {
    sandbox.method = "bwrap";
    sandbox.wrapperType = "wrappedDerivation";
    sandbox.net = "clearnet";
    sandbox.whitelistAudio = true;
    sandbox.whitelistDbus = [ "user" ];  # notifications
    sandbox.whitelistWayland = true;
    sandbox.extraHomePaths = [
      "Music"
      "Pictures"
      "Pictures/servo-macros"
      "Videos"
      "Videos/servo"
      "tmp"
    ];

    suggestedPrograms = [ "gnome-keyring" ];
  };
}
