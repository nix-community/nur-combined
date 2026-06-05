{ pkgs, ... }:
{
  sane.programs."engrampa" = {
    packageUnwrapped = pkgs.rmDbusServices pkgs.engrampa;
    sandbox.whitelistWayland = true;
    sandbox.autodetectCliPaths = "existingOrParent";
    sandbox.extraHomePaths = [
      "archive"
      "Books/Articles"
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
