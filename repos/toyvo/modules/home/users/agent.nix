{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.nixcfg;
in
{
  options.nixcfg.users.agent.enable = lib.mkEnableOption "Enable ai agent profile";

  config = lib.mkIf cfg.users.agent.enable {
    programs = {
      man.package = pkgs.man;
    };
  };
}
