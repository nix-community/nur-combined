{ pkgs, lib, ... }:
{
  home.activation = {
    betterdiscord = lib.hm.dag.entryAfter ["writeBoundary"] ''
PATH=${lib.makeBinPath (with pkgs; [ curl custom.colorpipe betterdiscordctl ])}:$PATH
BETTERDISCORD_CSS_TEMPLATE=${./custom.css}
${builtins.readFile ./activation.sh}
    '';
  };
}
