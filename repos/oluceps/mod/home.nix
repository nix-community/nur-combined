{
  flake.modules.nixos.home =
    {
      lib,
      pkgs,
      config,
      ...
    }:
    let
      inherit (config.identity) user;
      homeCfgAttr = import ../home { inherit pkgs lib config; };
    in
    {
      systemd.tmpfiles.rules =
        (map (n: "d /home/${user}/.config/${n} - ${user} ${user} - -") homeCfgAttr.dirs)
        ++ (lib.foldlAttrs (
          acc: n: v:
          acc ++ lib.singleton "L+ ${n} - ${user} ${user} - ${v}"
        ) [ ] homeCfgAttr.files);
    };
}
