{ pkgs, lib, ... }:
{
  home.activation = {
    obsidian = lib.hm.dag.entryAfter ["writeBoundary"] ''
PATH=${pkgs.custom.colorpipe}/bin:$PATH
OBSIDIAN_CSS_TEMPLATE=${./custom.css}
${builtins.readFile ./activation.sh}
    '';
  };
}
