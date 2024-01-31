{ pkgs, ... }:
{
  sane.programs.imagemagick = {
    sandbox.method = "bwrap";
    sandbox.wrapperType = "wrappedDerivation";
    sandbox.whitelistPwd = true;
    sandbox.autodetectCliPaths = true;  #< arg formatting is complicated enough that this won't always work.
    packageUnwrapped = pkgs.imagemagick.override {
      ghostscriptSupport = true;
    };
    suggestedPrograms = [ "ghostscript" ];
  };
}
