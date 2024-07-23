{ config, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.abszero.zramSwap;
in

{
  options.abszero.zramSwap.enable = mkEnableOption "compressed ram swap device";

  config = mkIf cfg.enable {
    zramSwap = {
      enable = true;
      memoryPercent = 200;
    };
    # https://wiki.archlinux.org/title/Zram#Optimizing_swap_on_zram
    boot.kernel.sysctl = {
      "vm.swappiness" = 180;
      "vm.watermark_boost_factor" = 0;
      "vm.watermark_scale_factor" = 125;
      "vm.page-cluster" = 0;
    };
  };
}
