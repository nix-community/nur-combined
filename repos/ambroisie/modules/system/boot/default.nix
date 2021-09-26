{ config, lib, ... }:
let
  cfg = config.my.system.boot;
in
{
  options.my.system.boot = with lib; {
    tmp = {
      clean = mkEnableOption "clean `/tmp` on boot.";

      tmpfs = my.mkDisableOption "mount `/tmp` as a tmpfs on boot.";
    };
  };

  config = {
    boot = {
      cleanTmpDir = cfg.tmp.clean;

      tmpOnTmpfs = cfg.tmp.tmpfs;
    };
  };
}
