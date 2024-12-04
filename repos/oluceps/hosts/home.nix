{
  lib,
  pkgs,
  user,
  ...
}:
let
  homeCfgAttr = import ../home { inherit pkgs lib user; };
in
{
  systemd.tmpfiles.rules = lib.foldlAttrs (
    acc: n: v:
    acc ++ lib.singleton "L+ ${n} - - - - ${v}"
  ) [ ] homeCfgAttr;
}
