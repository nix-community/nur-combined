{ pkgs, ... }:
{
  sane.programs."mate.engrampa" = {
    packageUnwrapped = pkgs.rmDbusServices pkgs.mate.engrampa;
    sandbox.whitelistWayland = true;
    sandbox.autodetectCliPaths = "existingOrParent";
    sandbox.extraHomePaths = [
      "archive"
      "Books/Audiobooks"
      "Books/Books"
      "Books/Visual"
      "Books/local"
      "Books/servo"
      "records"
      "ref"
      "tmp"
    ];
  };
}
