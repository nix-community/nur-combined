{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
{
  options.eownerdead.zfs = mkEnableOption (mdDoc ''
    My ZFS configuration
  '');

  config = mkIf config.eownerdead.zfs {
    services.zfs = {
      autoSnapshot.enable = true;
      trim = {
        enable = mkDefault true;
        interval = mkDefault "monthly";
      };
      autoScrub = {
        enable = mkDefault true;
      };
    };
  };
}
