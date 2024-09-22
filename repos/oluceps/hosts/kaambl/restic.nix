{ config, ... }:
{
  services.restic = {
    backups = {
      # critic = {
      #   passwordFile = config.age.secrets.wg.path;
      #   repository = "rclone:sec:crit";
      #   rcloneConfigFile = config.age.secrets.rclone-conf.path;
      #   paths = map (n: "/home/${user}/${n}") [
      #     "Books"
      #     "Pictures"
      #     "Music"
      #   ];
      #   extraBackupArgs = [
      #     "--exclude-caches"
      #     "--no-scan"
      #     "--retry-lock 2h"
      #   ];
      #   pruneOpts = [ "--keep-daily 3" ];
      #   timerConfig = {
      #     OnCalendar = "daily";
      #     RandomizedDelaySec = "4h";
      #     FixedRandomDelay = true;
      #     Persistent = true;
      #   };
      # };
    };
  };
}
