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
      tmp = {
        cleanOnBoot = cfg.tmp.clean;

        useTmpfs = cfg.tmp.tmpfs;
      };
    };
  };
}
