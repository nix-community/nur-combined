{ config, lib, pkgs, ... }:
let
  cfg = config.sane.hal.pine64-pinephone;
in
{
  config = lib.mkIf cfg.enable {
    # kernel compat (2024/09/11: 6c526c00)
    # - linux-armbian.override { usePmosConfig = true; withNixpkgsConfig = false; }:  no WiFi (USBC-eth works though); no modem; charging works; cameras works (linuxu 6.10.9)
    # - linux-armbian:  WiFi, modem (via megi's modem_power patch); charging (via megi's ANX7688 patches); NO cameras
    # - linux-postmarketos-allwinner: it's my daily driver
    # kernel compat (2024/08/31: b9cd911c)
    # - linux-postmarketos-allwinner: it's my daily driver
    # - linux_latest, i.e. mainline 6.10.7: WiFi works; modem works; charging requires ANX7688 patches; display requires CONFIG_FB_SIMPLE=y
    #   - wifi is spotty
    # - linux_testing, i.e. 6.11.0-rc5: WiFi works; charging & display works with the 6.10 patches; megi's modem-power patch doesn't apply
    #   - wifi feels no better than 6.10
    # kernel compatibility (2024/05/22: 03dab630)
    # - linux-megous: boots to ssh, desktop
    #   - camera apps: megapixels (no cameras found), snapshot (no cameras found)
    # - linux-postmarketos-allwinner: boots to ssh. desktop ONLY if "anx7688" is in the initrd.availableKernelModules.
    #   - camera apps: megapixels (both rear and front cameras work), `cam -l` (finds only the rear camera), snapshot (no cameras found)
    # - linux-megous.override { withMegiPinephoneConfig = true; }: NO SSH, NO SIGNS OF LIFE
    # - linux-megous.override { withFullConfig = false; }: boots to ssh, no desktop
    #
    # boot.kernelPackages = pkgs.linuxPackagesFor (pkgs.linux-postmarketos-allwinner.override {
    #   withModemPower = true;
    #   # withPmosPatches = false;
    # });
    #
    # boot.kernelPackages = pkgs.linuxPackagesFor pkgs.linux-megous;
    # boot.kernelPackages = pkgs.linuxPackagesFor (pkgs.linux-megous.override {
    #   withFullConfig = false;
    # });
    # boot.kernelPackages = pkgs.linuxPackagesFor (pkgs.linux-megous.override {
    #   withMegiPinephoneConfig = true;  #< N.B.: does not boot as of 2024/05/22!
    # });
    # boot.kernelPackages = pkgs.linuxPackagesFor pkgs.linux-manjaro;
    # boot.kernelPackages = pkgs.linuxPackagesFor pkgs.linux_latest;
    # boot.kernelPackages = pkgs.linuxPackagesFor pkgs.linux_testing;
    boot.kernelPackages = pkgs.linuxPackagesFor pkgs.linux-armbian;
    # boot.kernelPackages = pkgs.linuxPackagesFor (pkgs.linux-armbian.override {
    #   usePmosConfig = true;
    #   withNixpkgsConfig = true;
    #   withFullConfig = true;
    #   withModemPower = true;
    # });

    # nixpkgs.hostPlatform.linux-kernel becomes stdenv.hostPlatform.linux-kernel
    # ^ but only if using flakes (or rather, if *not* using `nixpkgs.nixos` to construct the host config)
    # nixpkgs.hostPlatform.linux-kernel = {
    #   # defaults:
    #   name = "aarch64-multiplatform";
    #   # baseConfig: defaults to "defconfig";
    #   # baseConfig = "pinephone_defconfig";  #< N.B.: ignored by `pkgs.linux-megous`
    #   DTB = true;  #< DTB: compile device tree blobs
    #   # autoModules (default: true): for config options not manually specified, answer `m` to anything which supports it.
    #   # - this effectively builds EVERY MODULE SUPPORTED.
    #   autoModules = true;  #< N.B.: ignored by `pkgs.linux-megous`
    #   # preferBuiltin (default: false; true for rpi): for config options which default to `Y` upstream, build them as `Y` (overriding `autoModules`)
    #   # preferBuiltin = false;

    #   # build a compressed kernel image: without this i run out of /boot space in < 10 generations
    #   # target = "Image";  # <-- default
    #   target = "Image.gz";  # <-- compress the kernel image
    #   # target = "zImage";  # <-- confuses other parts of nixos :-(
    # };

    # boot.initrd.kernelModules = [
    #   "drm"  #< force drm to be plugged
    # ];
    boot.initrd.availableKernelModules = [
      # see <repo:postmarketOS/pmaports:device/main/device-pine64-pinephone/modules-initfs>
      # - they include sun6i_mipi_dsi sun4i_drm pwm_sun4i sun8i_mixer anx7688 gpio_vibra pinephone_keyboard
      # "anx7688" #< historically required for display initialization and functional cameras (pre-2024-09-18)
      "axp20x_adc"  #< required for display initialization (if not compiled in)

      # full list of modules active post-boot with EITHER of:
      # - the linux-megous kernel + autoModules=true:
      # - mainline 6.11.0 + autoModules=true
      # - `lsmod | sort | cut -d ' ' -f 1`
      # "8723cs"
      # "axp20x_adc"
      # "axp20x_battery"
      # "axp20x_pek"
      # "axp20x_usb_power"
      # "backlight"
      # "blake2b_generic"
      # "bluetooth"
      # "bridge"
      # "btbcm"
      # "btqca"
      # "btrfs"
      # "btrtl"
      # "cdc_ether"
      # "cec"
      # "cfg80211"
      # "chacha_neon"
      # "crc_ccitt"
      # "crct10dif_ce"
      # "crypto_engine"
      # "display_connector"  #< NOT FOUND in pmos
      # "drm"
      # "drm_display_helper"
      # "drm_dma_helper"
      # "drm_kms_helper"
      # "drm_shmem_helper"
      # "dw_hdmi"
      # "dw_hdmi_cec"  #< NOT FOUND in pmos
      # "dw_hdmi_i2s_audio"
      # "ecc"
      # "ecdh_generic"
      # "fuse"
      # "gc2145"  #< NOT FOUND in megous-no-autoModules
      # "goodix_ts"
      # "gpio_vibra"  #< NOT FOUND in megous-no-autoModules
      # "gpu_sched"
      # "hci_uart"
      # "i2c_gpio"
      # "inv_mpu6050"  #< NOT FOUND in megous-no-autoModules
      # "inv_mpu6050_i2c"  #< NOT FOUND in megous-no-autoModules
      # "inv_sensors_timestamp"  #< NOT FOUND in megous-no-autoModules
      # "ip6_udp_tunnel"
      # "ip6t_rpfilter"
      # "ip_set"
      # "ip_set_hash_ipport"
      # "ip_tables"
      # "ipt_rpfilter"
      # "joydev"
      # "led_class_flash"  #< NOT FOUND in megous-no-autoModules
      # "led_class_multicolor"
      # "leds_group_multicolor"
      # "leds_sgm3140"  #< NOT FOUND in megous-no-autoModules
      # "ledtrig_pattern"  #< NOT FOUND in megous-no-autoModules
      # "libarc4"
      # "libchacha"
      # "libchacha20poly1305"
      # "libcrc32c"
      # "libcurve25519_generic"
      # "lima"
      # "llc"
      # "mac80211"
      # "macvlan"
      # "mc"
      # "modem_power"
      # "mousedev"
      # "nf_conntrack"
      # "nf_defrag_ipv4"
      # "nf_defrag_ipv6"
      # "nf_log_syslog"
      # "nf_nat"
      # "nf_tables"
      # "nfnetlink"
      # "nft_chain_nat"
      # "nft_compat"
      # "nls_cp437"
      # "nls_iso8859_1"
      # "nvmem_reboot_mode"
      # "ov5640"
      # "panel_sitronix_st7703"
      # "phy_sun6i_mipi_dphy"
      # "pinctrl_axp209"  #< NOT FOUND in pmos
      # "pinephone_keyboard"  #< NOT FOUND in megous-no-autoModules
      # "poly1305_neon"
      # "polyval_ce"
      # "polyval_generic"
      # "ppkb_manager"  #< NOT FOUND in megous-no-autoModules
      # "pwm_bl"
      # "pwm_sun4i"
      # "qrtr"
      # "raid6_pq"
      # "rfkill"
      # "rtw88_8703b"
      # "rtw88_8723cs"
      # "rtw88_8723x"
      # "rtw88_core"
      # "rtw88_sdio"
      # "sch_fq_codel"
      # "sm4"
      # "snd_hrtimer"
      # "snd_seq"
      # "snd_seq_device"
      # "snd_seq_dummy"
      # "snd_soc_bt_sco"
      # "snd_soc_ec25"  #< NOT FOUND in megous-no-autoModules
      # "snd_soc_hdmi_codec"
      # "snd_soc_simple_amplifier"
      # "snd_soc_simple_card"
      # "snd_soc_simple_card_utils"
      # "st_magn"
      # "st_magn_i2c"
      # "st_magn_spi"  #< NOT FOUND in pmos
      # "st_sensors"
      # "st_sensors_i2c"
      # "st_sensors_spi"  #< NOT FOUND in pmos
      # "stk3310"  #< NOT FOUND in megous-no-autoModules
      # "stp"
      # "sun4i_drm"
      # "sun4i_i2s"
      # "sun4i_lradc_keys"  #< NOT FOUND in megous-no-autoModules
      # "sun4i_tcon"
      # "sun50i_codec_analog"
      # "sun6i_csi"
      # "sun6i_dma"
      # "sun6i_mipi_dsi"
      # "sun8i_a33_mbus"  #< NOT FOUND in megous-no-autoModules
      # "sun8i_adda_pr_regmap"
      # "sun8i_ce"  #< NOT FOUND in pmos
      # "sun8i_codec"  #< NOT FOUND in megous-no-autoModules
      # "sun8i_di"  #< NOT FOUND in megous-no-autoModules
      # "sun8i_drm_hdmi"
      # "sun8i_mixer"
      # "sun8i_rotate"  #< NOT FOUND in megous-no-autoModules
      # "sun8i_tcon_top"
      # "sun9i_hdmi_audio"  #< NOT FOUND in megous-no-autoModules
      # "sunxi_cedrus"
      # "sunxi_wdt"  #< NOT FOUND in pmos
      # "tap"
      # "typec"  #< NOT FOUND in pmos
      # "udp_tunnel"
      # "uio"  #< NOT FOUND in pmos
      # "uio_pdrv_genirq"
      # "usbnet"
      # "v4l2_async"
      # "v4l2_cci" #< NOT FOUND in pmos
      # "v4l2_flash_led_class"  #< NOT FOUND in megous-no-autoModules
      # "v4l2_fwnode"
      # "v4l2_mem2mem"
      # "videobuf2_common"
      # "videobuf2_dma_contig"
      # "videobuf2_memops"
      # "videobuf2_v4l2"
      # "videodev"
      # "wireguard"
      # "x_tables"
      # "xor"
      # "xor_neon"
      # "xt_LOG"
      # "xt_conntrack"
      # "xt_iprange"
      # "xt_nat"
      # "xt_pkttype"
      # "xt_set"
      # "xt_tcpudp"
      # "zram"
    ];
  };
}
