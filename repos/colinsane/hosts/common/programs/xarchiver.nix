{ pkgs, ... }:
{
  sane.programs.xarchiver.packageUnwrapped = pkgs.xarchiver.override {
    # unar doesn't cross compile well, so disable support for it
    unar = null;
  };
}
