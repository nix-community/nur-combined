{ pkgs, ... }:
{
  sane.programs."mate.engrampa" = {
    packageUnwrapped = pkgs.rmDbusServices pkgs.mate.engrampa;
    sandbox.method = "bunpen";
    sandbox.whitelistWayland = true;
    sandbox.autodetectCliPaths = "existingOrParent";
    sandbox.extraHomePaths = [
      "archive"
      "Books/local"
      "Books/servo"
      "records"
      "ref"
      "tmp"
    ];
  };
}
