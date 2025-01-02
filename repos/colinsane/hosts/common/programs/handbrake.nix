{ ... }:
{
  sane.programs.handbrake = {
    buildCost = 1;

    sandbox.mesaCacheDir = ".cache/handbrake/mesa";  # TODO: is this the correct app-id?

    sandbox.whitelistDbus = [ "user" ];  # notifications
    sandbox.whitelistWayland = true;
    sandbox.extraHomePaths = [
      "Music"
      "Pictures/from"  # e.g. videos filmed from my phone
      "Videos/local"
      "Videos/servo"
      "tmp"
    ];
    sandbox.autodetectCliPaths = true;
  };
}
