{ config, lib, pkgs, ... }:
let
  cfg = config.sane.hal.pine64;
in
{
  options = {
    sane.hal.pine64.enable = lib.mkEnableOption "pine64-specific hardware support";
  };

  config = lib.mkIf cfg.enable {
    # kernel compatibility (2024/05/22: 03dab630)
    # - linux-megous: boots to ssh, desktop
    #   - camera apps: megapixels (no cameras found), snapshot (no cameras found)
    # - linux-postmarketos-allwinner: boots to ssh. desktop ONLY if "anx7688" is in the initrd.availableKernelModules.
    #   - camera apps: megapixels (both rear and front cameras work), `cam -l` (finds only the rear camera), snapshot (no cameras found)
    # - linux-megous.override { withMegiPinephoneConfig = true; }: NO SSH, NO SIGNS OF LIFE
    # - linux-megous.override { withFullConfig = false; }: boots to ssh, no desktop
    #
    boot.kernelPackages = pkgs.linuxPackagesFor (pkgs.linux-postmarketos-allwinner.override {
      withModemPower = true;
    });
    # boot.kernelPackages = pkgs.linuxPackagesFor pkgs.linux-megous;
    # boot.kernelPackages = pkgs.linuxPackagesFor (pkgs.linux-megous.override {
    #   withFullConfig = false;
    # });
    # boot.kernelPackages = pkgs.linuxPackagesFor (pkgs.linux-megous.override {
    #   withMegiPinephoneConfig = true;  #< N.B.: does not boot as of 2024/05/22!
    # });
    # boot.kernelPackages = pkgs.linuxPackagesFor pkgs.linux-manjaro;
    # boot.kernelPackages = pkgs.linuxPackagesFor pkgs.linux_latest;

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
      "anx7688" #< required for display initialization and functional cameras
      # full list of modules active post-boot with the linux-megous kernel + autoModules=true:
      # - `lsmod | sort | cut -d ' ' -f 1`
      # "8723cs"
      # "axp20x_adc"  #< NOT FOUND in megous-no-autoModules
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
      # "ip6t_rpfilter"
      # "ip6_udp_tunnel"
      # "ip_set"
      # "ip_set_hash_ipport"
      # "ip_tables"
      # "ipt_rpfilter"
      # "joydev"
      # "led_class_flash"  #< NOT FOUND in megous-no-autoModules
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
      # "nfnetlink"
      # "nf_tables"
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
      # "snd_soc_bt_sco"
      # "snd_soc_ec25"  #< NOT FOUND in megous-no-autoModules
      # "snd_soc_hdmi_codec"
      # "snd_soc_simple_amplifier"
      # "snd_soc_simple_card"
      # "snd_soc_simple_card_utils"
      # "stk3310"  #< NOT FOUND in megous-no-autoModules
      # "st_magn"
      # "st_magn_i2c"
      # "st_magn_spi"  #< NOT FOUND in pmos
      # "stp"
      # "st_sensors"
      # "st_sensors_i2c"
      # "st_sensors_spi"  #< NOT FOUND in pmos
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
      # "sunxi_wdt"  #< NOT FOUND in pmos
      # "tap"
      # "typec"  #< NOT FOUND in pmos
      # "udp_tunnel"
      # "uio"  #< NOT FOUND in pmos
      # "uio_pdrv_genirq"
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
      # "xor"
      # "x_tables"
      # "xt_conntrack"
      # "xt_LOG"
      # "xt_nat"
      # "xt_pkttype"
      # "xt_set"
      # "xt_tcpudp"
      # "zram"
    ];

    # disable proximity sensor.
    # the filtering/calibration is bad that it causes the screen to go fully dark at times.
    # boot.blacklistedKernelModules = [ "stk3310" ];

    boot.kernelParams = [
      # without this some GUI apps fail: `DRM_IOCTL_MODE_CREATE_DUMB failed: Cannot allocate memory`
      # this is because they can't allocate enough video ram.
      # see related nixpkgs issue: <https://github.com/NixOS/nixpkgs/issues/260222>
      # TODO(2023/12/03): remove once mesa 23.3.1 lands: <https://github.com/NixOS/nixpkgs/pull/265740>
      #
      # the default CMA seems to be 32M.
      # i was running fine with 256MB from 2022/07-ish through 2022/12-ish, but then the phone quit reliably coming back from sleep (phosh): maybe a memory leak?
      # bumped to 512M on 2023/01
      # bumped to 1536M on 2024/05
      # `cat /proc/meminfo` to see CmaTotal/CmaFree if interested in tuning this.
      # kernel param mentioned here: <https://cateee.net/lkddb/web-lkddb/CMA_SIZE_PERCENTAGE.html>
      # i think cma mem isn't exclusive -- it can be used as ordinary `malloc`, still. i heard someone suggest the OS default should just be 50% memory to CMA.
      "cma=1536M"
      # 2023/10/20: potential fix for the lima (GPU) timeout bugs:
      # - <https://gitlab.com/postmarketOS/pmaports/-/issues/805#note_890467824>
      "lima.sched_timeout_ms=2000"
    ];

    # defined: https://www.freedesktop.org/software/systemd/man/machine-info.html
    # XXX colin: diabled until/unless it's actually needed.
    # environment.etc."machine-info".text = ''
    #   CHASSIS="handset"
    # '';

    # hardware.firmware makes the referenced files visible to the kernel, for whenever a driver explicitly asks for them.
    # these files are visible from userspace by following `/sys/module/firmware_class/parameters/path`
    #
    # mobile-nixos' /lib/firmware includes:
    #   rtl_bt          (bluetooth)
    #   anx7688-fw.bin  (USB-C chip: power negotiation, HDMI/dock)
    #   ov5640_af.bin   (camera module)
    # hardware.firmware = [ config.mobile.device.firmware ];
    # hardware.firmware = [ pkgs.rtl8723cs-firmware ];
    hardware.firmware = [
      (pkgs.linux-firmware-megous.override {
        # rtl_bt = false probably means no bluetooth connectivity.
        # N.B.: DON'T RE-ENABLE without first confirming that wake-on-lan works during suspend (rtcwake).
        # it seems the rtl_bt stuff ("bluetooth coexist") might make wake-on-LAN radically more flaky.
        rtl_bt = false;
      })
    ];

    ## TOW-BOOT: <https://tow-boot.org>
    # docs (pinephone specific): <https://github.com/Tow-Boot/Tow-Boot/tree/development/boards/pine64-pinephoneA64>
    # LED and button behavior is defined here: <https://github.com/Tow-Boot/Tow-Boot/blob/development/modules/tow-boot/phone-ux.nix>
    # - hold VOLDOWN: enter recovery mode
    #   - LED will turn aqua instead of yellow
    #   - recovery mode would ordinarily allow a selection of entries, but for pinephone i guess it doesn't do anything?
    # - hold VOLUP: force it to load the OS from eMMC?
    #   - LED will turn blue instead of yellow
    # boot LEDs:
    # - yellow = entered tow-boot
    # - 10 red flashes => poweroff means tow-boot couldn't boot into the next stage (i.e. distroboot)
    #   - distroboot: <https://source.denx.de/u-boot/u-boot/-/blob/v2022.04/doc/develop/distro.rst>)
    # we need space in the GPT header to place tow-boot.
    # only actually need 1 MB, but better to over-allocate than under-allocate
    sane.image.extraGPTPadding = 16 * 1024 * 1024;
    sane.image.firstPartGap = 0;
    sane.image.installBootloader = ''
      dd if=${pkgs.u-boot-pinephone}/u-boot-sunxi-with-spl.bin of=$out bs=1024 seek=8 conv=notrunc
    '';
    # sane.image.installBootloader = ''
    #   dd if=${pkgs.tow-boot-pinephone}/Tow-Boot.noenv.bin of=$out bs=1024 seek=8 conv=notrunc
    # '';

    sane.programs.geoclue2.suggestedPrograms = [
      "gps-share"
    ];
    sane.programs.nwg-panel.config.torch = "white:flash";
    sane.programs.swaynotificationcenter.config = {
      backlight = "backlight";  # /sys/class/backlight/*backlight*/brightness
    };

    services.udev.extraRules = let
      chmod = "${pkgs.coreutils}/bin/chmod";
      chown = "${pkgs.coreutils}/bin/chown";
    in ''
      # make Pinephone flashlight writable by user.
      # taken from postmarketOS: <repo:postmarketOS/pmaports:device/main/device-pine64-pinephone/60-flashlight.rules>
      SUBSYSTEM=="leds", DEVPATH=="*/*:flash", RUN+="${chmod} g+w /sys%p/brightness /sys%p/flash_strobe", RUN+="${chown} :video /sys%p/brightness /sys%p/flash_strobe"

      # make Pinephone front LEDs writable by user.
      SUBSYSTEM=="leds", DEVPATH=="*/*:indicator", RUN+="${chmod} g+w /sys%p/brightness", RUN+="${chown} :video /sys%p/brightness"
    '';

    systemd.services.unl0kr.preStart = let
      dmesg = "${pkgs.util-linux}/bin/dmesg";
      grep = "${pkgs.gnugrep}/bin/grep";
      modprobe = "${pkgs.kmod}/bin/modprobe";
    in ''
      # common boot failure:
      # blank screen (no backlight even), with the following log:
      # ```syslog
      # sun8i-dw-hdmi 1ee0000.hdmi: Couldn't get the HDMI PHY
      # ...
      # sun4i-drm display-engine: Couldn't bind all pipelines components
      # ...
      # sun8i-dw-hdmi: probe of 1ee0000.hdmi failed with error -17
      # ```
      #
      # in particular, that `probe ... failed` occurs *only* on failed boots
      # (the other messages might sometimes occur even on successful runs?)
      #
      # reloading the sun8i hdmi driver usually gets the screen on, showing boot text.
      # then restarting display-manager.service gets us to the login.
      #
      # NB: the above log is default level. though less specific, there's a `err` level message that also signals this:
      # sun4i-drm display-engine: failed to bind 1ee0000.hdmi (ops sun8i_dw_hdmi_ops [sun8i_drm_hdmi]): -17
      # NB: this is the most common, but not the only, failure mode for `display-manager`.
      # another error seems characterized by these dmesg logs, in which reprobing sun8i_drm_hdmi does not fix:
      # ```syslog
      # sun6i-mipi-dsi 1ca0000.dsi: Couldn't get the MIPI D-PHY
      # sun4i-drm display-engine: Couldn't bind all pipelines components
      # sun6i-mipi-dsi 1ca0000.dsi: Couldn't register our component
      # ```

      if (${dmesg} --kernel --level err --color=never --notime | ${grep} -q 'sun4i-drm display-engine: failed to bind 1ee0000.hdmi')
      then
        echo "reprobing sun8i_drm_hdmi"
        # if a command here fails it errors the whole service, so prefer to log instead
        ${modprobe} -r sun8i_drm_hdmi || echo "failed to unload sun8i_drm_hdmi"
        ${modprobe} sun8i_drm_hdmi || echo "failed to load sub8i_drm_hdmi"
      fi
    '';
  };
}

