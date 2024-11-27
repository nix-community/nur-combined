{ config, lib, pkgs, ... }:
let
  cfg = config.sane.hal.pine64-pinephone-pro;
  myCustomKernel = pkgs.linux-sane-pinephonepro.overrideAttrs (prev: {
    dontUnpack = true;
    dontPatch = true;
    dontConfigure = true;
    dontBuild = true;
    patchPhase = "";
    configurePhase = "";
    installPhase = ''
      cp -R ${../../../wip-linux/v03/out} $out
      cp -R ${../../../wip-linux/v03/dev} $dev
    '';
  });
in
{
  options = {
    sane.hal.pine64-pinephone-pro.enable = lib.mkEnableOption "pinephone-pro-specific hardware support";
  };

  config = lib.mkIf cfg.enable {
    # kernel compat (2024/09/22):
    # - linux-postmarketos-pinephonepro (6.6.0): boots to graphics; WiFi; Ethernet
    # - linux-sane-pinephonepro (6.11.0; pmos config ONLY): boots to graphics; Wifi; no ethernet
    #   - firewall.service fails b/c extensions "LOG" and "tcp" are missing
    #   - battery status is unknown
    #   - cameras, sound, etc untested
    # - linux-sane-pinephonepro (6.11.0; pmos config + nixpkgs config): FAILS TO BOOT
    # boot.kernelPackages = pkgs.linuxPackagesFor pkgs.linux-postmarketos-pinephonepro;
    # boot.kernelPackages = pkgs.linuxPackagesFor pkgs.linux-sane-pinephonepro;
    # boot.kernelPackages = pkgs.linuxPackagesFor myCustomKernel;
    # boot.initrd.extraFiles."/lib".source = "${config.system.modulesTree}/lib";

    sane.programs.alsa-ucm-conf.suggestedPrograms = [
      "pine64-alsa-ucm"  # upstreaming: https://github.com/alsa-project/alsa-ucm-conf/pull/375
    ];

    sane.programs.nwg-panel.config.torch = "white:flash";
    sane.programs.swaynotificationcenter.config = {
      backlight = "backlight";  # /sys/class/backlight/*backlight*/brightness
    };
    # XXX(2024/10/18): callaudiod changes the global audio config; this requires alsa configs to be 100% right,
    # else it'll change to something which produces no sound (like the "Voice Call" use case)
    # sane.programs.callaudiod.enableFor.user.colin = lib.mkForce false;

    services.udev.extraRules = let
      chmod = lib.getExe' pkgs.coreutils "chmod";
      chown = lib.getExe' pkgs.coreutils "chown";
    in ''
      # make flashlight/torch writable by user.
      # taken from postmarketOS: <repo:postmarketOS/pmaports:device/main/device-pine64-pinephone/60-flashlight.rules>
      SUBSYSTEM=="leds", DEVPATH=="*/*:flash", RUN+="${chmod} g+w /sys%p/brightness /sys%p/flash_strobe", RUN+="${chown} :video /sys%p/brightness /sys%p/flash_strobe"

      # make the front led (and all leds) user-writable (because why not)
      SUBSYSTEM=="leds", DEVPATH=="*/*", RUN+="${chmod} g+w /sys%p/brightness /sys%p/flash_strobe", RUN+="${chown} :video /sys%p/brightness"
    '';

    boot.kernelPatches = [
      {
        # TODO: upstream into nixpkgs. <repo:nixos/nixpkgs:pkgs/os-specific/linux/kernel/common-config.nix>
        name = "fix-module-builtin-mismatch";
        patch = null;
        extraStructuredConfig = with lib.kernel; {
          # nixpkgs specifies `SUN8I_DE2_CCU = yes`, but that in turn requires `SUNXI_CCU = yes` and NOT `= module`
          #   symptom: config fails to eval
          SUNXI_CCU = yes;
          # nixpkgs specifies `DRM = yes`, which causes `DRM_PANEL=y`.
          # in <repo:kernel.org/linux:include/drm/drm_panel.h> they branch based on if `CONFIG_BACKLIGHT_DEVICE` is a *builtin*,
          # hence we need to build it as a builtin to actually have a backlight!
          # same logic happens with nixpkgs `DRM_FBDEV_EMULATION = yes` => implies `CONFIG_DRM_KMS_HELPER=y`
          # and <repo:kernel.org/linux:include/drm/display/drm_dp_helper.h>
          BACKLIGHT_CLASS_DEVICE = yes;
        };
      }
    ];

    hardware.deviceTree.overlays = [
      {
        name = "rk3399-pinephone-pro-battery";
        dtsFile = ./rk3399-pinephone-pro-battery.dtso;
      }
      {
        name = "rk3399-pinephone-pro-camera";
        dtsFile = ./rk3399-pinephone-pro-camera.dtso;
      }
      {
        name = "rk3399-pinephone-pro-flash-led";
        dtsFile = ./rk3399-pinephone-pro-flash-led.dtso;
      }
      {
        name = "rk3399-pinephone-pro-lradc-fix";
        dtsFile = ./rk3399-pinephone-pro-lradc-fix.dtso;
      }
      {
        name = "rk3399-pinephone-pro-modem";
        dtsFile = ./rk3399-pinephone-pro-modem.dtso;
      }
      {
        name = "rk3399-pinephone-pro-sound";
        dtsFile = ./rk3399-pinephone-pro-sound.dtso;
      }
    ];

    # this seems to not actually be necessary (unless maybe my *overlay* #include's stuff)
    # hardware.deviceTree.dtboBuildExtraIncludePaths = let
    #   # extract the subset of the kernel source code which my devicetree references
    #   kernelSrc = pkgs.stdenv.mkDerivation {
    #     name = "kernel-sources";
    #     inherit (config.hardware.deviceTree.kernelPackage) src;
    #     dontBuild = true;
    #     installPhase = ''
    #       mkdir $out
    #       cp -R --parents arch/arm64/boot/dts $out
    #     '';
    #   };
    # in [
    #   "${kernelSrc}/arch/arm64/boot/dts/rockchip"
    # ];

    # system.build.initialRamdisk = lib.mkForce (pkgs.makeInitrd {
    #   # based on <repo:nixos/nixpkgs:nixos/modules/system/boot/stage-1.nix>
    #   # modified so that we ship *all* kernel modules in the initrd.
    #   # for boot.initrd.systemd version see here: <https://discourse.nixos.org/t/how-to-include-every-kernel-module-in-initrd/45844>
    #   # this creates an *excessively* large initrd, but somehow u-boot seems fine with that.
    #   name = "initrd-all-modules";
    #   inherit (config.boot.initrd) compressor compressorArgs prepend;
    #   contents = [
    #     {
    #       object = config.system.build.bootStage1;
    #       symlink = "/init";
    #     }
    #     {
    #       object = "${config.system.modulesTree}/lib/modules";
    #       symlink = "/lib/modules";
    #     }
    #     {
    #       object = "${config.hardware.firmware}/lib/firmware";
    #       symlink = "/lib/firmware";
    #     }
    #     # {
    #     #   object = pkgs.symlinkJoin {
    #     #     name = "initrd-modules-and-firmware";
    #     #     paths = [
    #     #       "${config.system.modulesTree}/lib"
    #     #       "${config.hardware.firmware}/lib"
    #     #     ];
    #     #   };
    #     #   symlink = "/lib";
    #     # }
    #     {
    #       object = pkgs.runCommand "initrd-kmod-blacklist-ubuntu" {
    #         src = "${pkgs.kmod-blacklist-ubuntu}/modprobe.conf";
    #         preferLocalBuild = true;
    #       } ''
    #         target=$out
    #         ${lib.getExe' pkgs.buildPackages.perl "perl"} -0pe 's/## file: iwlwifi.conf(.+?)##/##/s;' $src > $out
    #       '';
    #       symlink = "/etc/modprobe.d/ubuntu.conf";
    #     }
    #     {
    #       object = config.environment.etc."modprobe.d/nixos.conf".source;
    #       symlink = "/etc/modprobe.d/nixos.conf";
    #     }
    #     {
    #       object = pkgs.kmod-debian-aliases;
    #       symlink = "/etc/modprobe.d/debian.conf";
    #     }
    #   ] ++ (lib.mapAttrsToList
    #     (symlink: options: {
    #         inherit symlink;
    #         object = options.source;
    #     })
    #     config.boot.initrd.extraFiles
    #   );
    # });

    boot.extraModulePackages = [
      config.boot.kernelPackages.rk818-charger  #< rk818 battery/charger isn't mainline as of 2024-10-01
    ];

    # default nixos behavior is to error if a kernel module is provided by more than one package.
    # in fact, i'm _intentionally_ overwriting the in-tree modules, so inline this buildEnv logic
    # from <repo:nixos/nixpkgs:nixos/modules/system/boot/kernel.nix> AKA pkgs.aggregateModules
    # but configured to **ignore collisions**
    system.modulesTree = lib.mkForce [(
      (pkgs.aggregateModules
        ( config.boot.extraModulePackages ++ [ config.boot.kernelPackages.kernel ])
      ).overrideAttrs {
        # earlier items override the contents of later items
        ignoreCollisions = true;
        # checkCollisionContents = false;
      }
    )];

    boot.kernelModules = [
      # these don't get probed automatically, not sure why (shouldn't the device tree cause it to be auto-loaded?)
      # but are needed for battery capacity/charging info
      "rk818_battery"
      "rk818_charger"
    ];

    boot.initrd.availableKernelModules = [
      # see <repo:postmarketOS/pmaports:device/community/device-pine64-pinephonepro/modules-initfs>
      # - pmos includes: gpu_sched dw_wdt fusb302 panel_himax_hx8394 goodix_ts

      # these are all required for graphics in the initrd
      "panel_himax_hx8394"
      "pwm_bl"
      # highly likely, but didn't fully check, that these below are required for initrd graphics
      "rockchip_rga"
      "rockchip_vdec"
      "rockchipdrm"
      # speculatively (for my rk818-charger kernel module), might not need!
      "clk_rk808"
      "rk808_regulator"
      "rk8xx_core"
      "rk8xx_i2c"  #< required to read from sd card

      # these were found to be loaded after the initrd, and at least one is needed.
      # TODO: reduce this!
      "8250_dw"  #< needed for early serial output (over the 3.5mm plug)
      # "adc_keys"
      # "aes_ce_blk"
      # "af_packet"
      # "analogix_dp"
      # "atkbd"
      # "autofs4"
      # "blake2b_generic"
      # "bluetooth"
      # AVOID INCLUDING brcmfmac IN INITRD, ELSE WIFI FIRMWARE WILL FAIL TO LOAD
      # "brcmfmac"
      # "brcmfmac_wcc"
      # "brcmutil"
      # "btbcm"
      # "btqca"
      # "btrfs"
      # "btsdio"
      # "cec"
      # "cfg80211"
      # "chacha_neon"
      # "clk_rk808"
      # "coresight"
      # "coresight_cpu_debug"
      # "coresight_etm4x"
      # "cpufreq_ondemand"
      # "cqhci"
      # "crc16"
      # "crc32c_generic"
      # "crct10dif_ce"
      # "crypto_engine"
      # "drm_display_helper"
      # "drm_dma_helper"
      # "dw_hdmi"
      # "dw_mipi_dsi"
      # "dw_mmc"
      # "dw_mmc_pltfm"
      "dw_mmc_rockchip"  #< required to load stage2 from SD card
      # "dw_wdt"
      # "ecc"
      # "ecdh_generic"
      # "efi_pstore"
      # "evdev"
      "fan53555"  #< likely needed for early boot (before serial)
      # "fat"
      # "ff_memless"
      "fixed"  #< fixed-voltage regulators; likely needed for early boot (before serial)
      # "fuse"
      # "gf128mul"
      # "ghash_ce"
      # "goodix_ts"
      # "governor_simpleondemand"
      # "gpio_keys"
      "gpio_rockchip"  #< required to bring up regulators during initrd
      # "gpio_vibra"
      # "gpu_sched"
      # "hantro_vpu"
      # "hci_uart"
      # "i2c_mux"
      "i2c_rk3x"  #< required to load stage2 from SD card
      # "industrialio"
      # "industrialio_triggered_buffer"
      # "inv_mpu6050"
      # "inv_mpu6050_i2c"
      # "inv_mpu6050_spi"
      # "inv_sensors_timestamp"
      # "io_domain"
      # "ip6t_rpfilter"
      # "ip6_udp_tunnel"
      # "ip_set"
      # "ip_set_hash_ipport"
      # "ip_tables"
      # "ipt_rpfilter"
      # "joydev"
      # "kfifo_buf"
      # "led_class"
      # "led_class_multicolor"
      # "leds_gpio"
      # "leds_group_multicolor"
      # "libchacha"
      # "libchacha20poly1305"
      # "libcrc32c"
      # "libcurve25519_generic"
      # "libdes"
      # "libps2"
      # "loop"
      # "mc"
      # "md5"
      "mmc_block"  #< required to load stage2 from SD card
      # "mmc_core"
      # "mousedev"
      # "mtd"
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
      # "nvmem_rockchip_efuse"
      # "ofpart"
      # "panel_himax_hx8394"
      # "panfrost"
      # "phy_rockchip_emmc"
      "pinctrl_rockchip"  #< required by early boot (even before serial is available)
      # "pl330"
      # "poly1305_neon"
      # "polyval_ce"
      # "polyval_generic"
      # "pwm_bl"
      "pwm_rockchip"  #< i *think* this is needed for display out in initrd
      # "pwrseq_core"
      # "pwrseq_simple"
      # "qrtr"
      # "raid6_pq"
      # "regmap_spi"
      # "rfkill"
      # "rk808_regulator"
      # "rk818_battery"
      # "rk818_charger"
      # "rk8xx_core"
      # "rk8xx_i2c"
      # "rk_crypto"
      # "rockchip_dfi"
      # "rockchipdrm"
      # "rockchip_rga"
      # "rockchip_saradc"
      # "rockchip_thermal"
      # "rockchip_vdec"
      # "rtc_rk808"
      # "sch_fq_codel"
      # "sdhci"
      # "sdhci_of_arasan"
      # "sdhci_pltfm"
      # "serio"
      # "sha1_ce"
      # "sha256_arm64"
      # "sha2_ce"
      # "sm4"
      # "snd"
      # "snd_hrtimer"
      # "snd_seq"
      # "snd_seq_device"
      # "snd_seq_dummy"
      # "snd_timer"
      # "soundcore"
      # "spi_nor"
      # "spi_rockchip"
      # "tun"
      # "udp_tunnel"
      # "uinput"
      # "uio"
      # "uio_pdrv_genirq"
      # "v4l2_h264"
      # "v4l2_jpeg"
      # "v4l2_mem2mem"
      # "v4l2_vp9"
      # "vfat"
      # "videobuf2_common"
      # "videobuf2_dma_contig"
      # "videobuf2_dma_sg"
      # "videobuf2_memops"
      # "videobuf2_v4l2"
      # "videodev"
      # "vivaldi_fmap"
      # "wireguard"
      # "xor"
      # "xor_neon"
      # "x_tables"
      # "xt_conntrack"
      # "xt_iprange"
      # "xt_LOG"
      # "xt_nat"
      # "xt_pkttype"
      # "xt_set"
      # "xt_tcpudp"
      # "zram"
    ];

    boot.kernelParams = [
      # XXX(2024-11-26): SPECULATIVE fix for camera bringup; TODO: check if this is actually required?
      "cma=512M"
    ];
  };
}
