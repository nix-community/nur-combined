{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.nixcfg.users.hermes;
  hermesUid =
    if config.ids ? uids && config.ids.uids ? hermes then
      config.ids.uids.hermes
    else
      lib.mkDefault 1005;
  hermesGid =
    if config.ids ? gids && config.ids.gids ? hermes then
      config.ids.gids.hermes
    else
      lib.mkDefault 1005;
in
{
  options.nixcfg.users.hermes.enable = lib.mkEnableOption "hermes system user";

  config = lib.mkIf cfg.enable {
    users.users.hermes = lib.mkIf pkgs.stdenv.isLinux {
      uid = hermesUid;
      subUidRanges = [
        {
          startUid = 200000;
          count = 65536;
        }
      ];
      subGidRanges = [
        {
          startGid = 200000;
          count = 65536;
        }
      ];
    };
    users.groups.hermes = lib.mkIf pkgs.stdenv.isLinux {
      gid = hermesGid;
    };
  };
}
