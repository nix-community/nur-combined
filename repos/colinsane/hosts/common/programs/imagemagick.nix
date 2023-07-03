{ pkgs, ... }:
{
  sane.programs.imagemagick = {
    package = pkgs.imagemagick.override {
      ghostscriptSupport = true;
    };
    suggestedPrograms = [ "ghostscript" ];
  };
}
