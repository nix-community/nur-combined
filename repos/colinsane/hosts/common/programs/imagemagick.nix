{ pkgs, ... }:
{
  sane.programs.imagemagick = {
    packageUnwrapped = pkgs.imagemagick.override {
      ghostscriptSupport = true;
    };
    suggestedPrograms = [ "ghostscript" ];
  };
}
