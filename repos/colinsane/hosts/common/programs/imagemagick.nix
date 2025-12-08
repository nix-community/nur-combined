{ pkgs, ... }:
{
  sane.programs.imagemagick = {
    buildCost = 1;

    packageUnwrapped = pkgs.imagemagickBig;  #< includes ghostscript support
    # suggestedPrograms = [ "ghostscript" ];  #< XXX: needed? is `ghostscriptSupport = true` alone not enough??

    sandbox.wrapperType = "inplace";  # /etc/ImageMagick-7/delegates.xml refers to bins by absolute path
    sandbox.whitelistPwd = true;
    sandbox.autodetectCliPaths = "existingOrParent";  #< arg formatting is complicated enough that this won't always work.
  };
}
