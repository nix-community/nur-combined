{ lib, pkgs, ... }:
let
  thefuckConfig = lib.sourceFilesBySuffices ./. [ ".py" ];
in
{
  programs.thefuck = {
    enable = true;
    package = pkgs.thefuck.overrideAttrs {
      patches = [ ./thefuck.patch ];
    };
    enableInstantMode = true;
  };
  xdg.configFile."thefuck" = {
    source = thefuckConfig;
    recursive = true;
  };
}
