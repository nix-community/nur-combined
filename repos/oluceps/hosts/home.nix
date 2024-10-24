{ lib, pkgs, ... }:
let
  homeCfgAttr = (import ../home { inherit pkgs lib; });
in
{
  systemd.tmpfiles.rules = lib.foldlAttrs (
    acc: n: v:
    acc ++ lib.singleton "L+ ${v} - - - - ${n}"
  ) [ ] homeCfgAttr;
}
