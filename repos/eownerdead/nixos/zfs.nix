{ lib, pkgs, config, ... }:
with lib; {
  options.eownerdead.zfs = mkEnableOption (mdDoc ''
    I recommend when you are using ZFS.
  '');

  config = mkIf config.eownerdead.zfs {
    services.zfs = {
      trim = {
        enable = mkDefault true;
        interval = mkDefault "monthly";
      };
      autoScrub = {
        enable = mkDefault true;
        pools = mkDefault [ "rpool" ];
        interval = mkDefault "weekly";
      };
    };
  };
}
