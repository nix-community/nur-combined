{ pkgs, ... }:
{
  sane.programs.xarchiver = {
    packageUnwrapped = pkgs.xarchiver.override {
      # unar doesn't cross compile well, so disable support for it
      unar = null;
    };
    buildCost = 1;

    sandbox.whitelistWayland = true;
    sandbox.extraHomePaths = [
      "archive"
      "ref"
      "tmp"
      "use"
    ];
    # allow extracting an archive in the rare case it's outside the common directories
    sandbox.autodetectCliPaths = "existing";
  };
}
