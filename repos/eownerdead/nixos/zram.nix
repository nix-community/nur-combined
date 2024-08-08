{ lib, config, ... }:
{
  options.eownerdead.zram = lib.mkEnableOption ''
    Compressed RAM as swap.
  '';

  config = lib.mkIf config.eownerdead.zram {
    zramSwap.enable = true;

    # https://wiki.archlinux.org/title/Zram#Optimizing_swap_on_zram
    boot.kernel.sysctl = {
      "vm.swappiness" = 180;
      "vm.watermark_boost_factor" = 0;
      "vm.watermark_scale_factor" = 125;
      "vm.page-cluster" = 0;
    };
  };
}
