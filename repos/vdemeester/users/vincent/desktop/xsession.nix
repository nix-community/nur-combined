{ config, pkgs, ... }:

{
  xsession = {
    enable = true;
    initExtra = ''
      ${pkgs.xlibs.xmodmap}/bin/xmodmap ${config.home.homeDirectory}.Xmodmap &
    '';
    pointerCursor = {
      package = pkgs.vanilla-dmz;
      name = "Vanilla-DMZ";
    };
  };
}
