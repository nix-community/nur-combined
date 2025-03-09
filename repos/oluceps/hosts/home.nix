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
  systemd.tmpfiles.rules =
    (map (n: "d /home/${user}/.config/${n} - ${user} ${user} - -") homeCfgAttr.dirs)
    ++ (lib.foldlAttrs (
      acc: n: v:
      acc ++ lib.singleton "L+ ${n} - ${user} ${user} - ${v}"
    ) [ ] homeCfgAttr.files);
}
