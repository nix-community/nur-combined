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
      hjem.users.${user} = {
        enable = true;
        xdg.config.files = lib.mapAttrs' (path: src: {
          name = lib.removePrefix "/home/${user}/.config/" path;
          value.source = src;
        }) homeCfgAttr.files;
      };
    };
}
