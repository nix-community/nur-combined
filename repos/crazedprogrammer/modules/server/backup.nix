{ config, pkgs, lib, ... }:

{
  services.rsnapshot = {
    enable = true;
    cronIntervals = {
      hourly = "0 * * * *";
      daily = "0 5 * * *";
      weekly = "0 5 * * 0";
    };
    extraConfig = lib.replaceChars [" "] ["\t"] ''
      snapshot_root /mnt/backup
      backup /home/ home/
      backup /var/www/ www/
      backup /var/lib/ lib/

      retain hourly 24
      retain daily 7
      retain weekly 1000
    '';
  };
}
