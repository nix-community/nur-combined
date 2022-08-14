{ pkgs, lib, ... }:
{
  home.activation = {
    betterdiscord = lib.hm.dag.entryAfter ["writeBoundary"] ''
PATH=${pkgs.custom.colorpipe}/bin:${pkgs.betterdiscordctl}/bin:$PATH
BETTERDISCORD_CSS_TEMPLATE=${./custom.css}
${builtins.readFile ./activation.sh}
    '';
  };
}
