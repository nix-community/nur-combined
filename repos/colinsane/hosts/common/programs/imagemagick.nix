{ pkgs, ... }:
{
  sane.programs.imagemagick = {
    buildCost = 1;

    sandbox.wrapperType = "inplace";  # /etc/ImageMagick-7/delegates.xml refers to bins by absolute path
    sandbox.whitelistPwd = true;
    sandbox.autodetectCliPaths = "existingOrParent";  #< arg formatting is complicated enough that this won't always work.
    packageUnwrapped = pkgs.imagemagick.override {
      ghostscriptSupport = true;
    };
    # suggestedPrograms = [ "ghostscript" ];  #< XXX: needed? is `ghostscriptSupport = true` alone not enough??
  };
}
