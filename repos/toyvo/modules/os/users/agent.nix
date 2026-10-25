{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.nixcfg.users.agent;
in
{
  options.nixcfg.users.agent.enable = lib.mkEnableOption "agent system user";

  config = lib.mkIf cfg.enable {
    users.users.agent = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
      uid = config.ids.uids.agent;
      group = "agent";
      isSystemUser = true;
      shell = lib.mkDefault pkgs.bash;
      description = "AI agent service user";
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
    users.groups.agent = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
      gid = config.ids.gids.agent;
    };
  };
}
