# device support for samsung XE303C12 "google-snow" model, specifically.
# see: <https://wiki.postmarketos.org/wiki/Samsung_Chromebook_(google-snow)>
# - build logs: <https://images.postmarketos.org/bpo/edge/google-snow/console/>
# see: <https://github.com/thefloweringash/kevin-nix>
# - related "depthcharge" chromebook, built with nix
# see: <https://mobile.nixos.org/devices/lenovo-wormdingler.html>
# - above module, integrated into an image builder
# - implementation in modules/system-types/depthcharge
# see: <https://web.archive.org/web/20191103000916/http://www.chromium.org/chromium-os/firmware-porting-guide/using-nv-u-boot-on-the-samsung-arm-chromebook>
# - referenced from u-boot `doc/` directory
# - <https://web.archive.org/web/20220813062811/https://www.chromium.org/chromium-os/how-tos-and-troubleshooting/using-an-upstream-kernel-on-snow/>
# - <https://web.archive.org/web/20240119111314/https://www.chromium.org/chromium-os/developer-information-for-chrome-os-devices/custom-firmware/>
# - google exynos5_defconfig: <https://chromium.googlesource.com/chromiumos/overlays/chromiumos-overlay/%2B/HEAD/eclass/cros-kernel>
# see: <repo:postmarketOS/pmaports:device/community/device-google-snow>
# - <https://gitlab.com/postmarketOS/boot-deploy/-/blob/5f08ebb05a520d0e6bccfcda324f12e4aac1623f/boot-deploy-functions.sh#L872>
# - deviceinfo:
#   - deviceinfo_flash_method="none"
#   - deviceinfo_cgpt_kpart="/boot/vmlinuz.kpart"
#   - deviceinfo_cgpt_kpart_start="8192"
#   - deviceinfo_cgpt_kpart_size="16384"
#   - deviceinfo_kernel_cmdline="console=null"
#   - deviceinfo_depthcharge_board="snow"
#   - deviceinfo_generate_depthcharge_image="true"
#   - deviceinfo_generate_extlinux_config="true"
# - modules-initfs:
#   - drm-dp-aux-bus
#   - panel-edp
#   - drm-kms-helper
#   - cros-ec-keyb
#   - sbs-battery
#   - tps65090-charger
#   - uas
#   - sd-mod
# - pmOS also uses a custom alsa UCM config
# - pmOS kernel package: linux-postmarketos-exynos5
# - pmOS firmware packages (for WiFi/Bluetooth): linux-firmware-mrvl linux-firmware-s5p-mfc
#
# pmOS image has disk layout:
# /dev/sdb1    8192    24575    16384    8M ChromeOS kernel
# /dev/sdb2   24576   548863   524288  256M EFI System
# /dev/sdb3  548864 31336414 30787551 14.7G Microsoft basic data
# - built using `depthcharge-tools`: <https://github.com/alpernebbi/depthcharge-tools>
# - expected chromeos disk layout documented: <https://www.chromium.org/chromium-os/developer-library/reference/device/disk-format/>
#
# typical boot process:
# - BIOS searches for a partition `ChromeOS Kernel Type GUID (fe3a2a5d-4f32-41a7-b725-accc3285a309)`
# - first 64K are reserved for sigantures (when verified boot is active)
# - then kernel, some datastructures (i.e. config.txt, the command line passed to the kernel), bootloader stub
# - BIOS loads kernel blob into RAM, then invokes the bootstub
# - bootloader stub is an EFI application. it setups up tables and jumps into the kernel.
#   - so potentially i could put any EFI application here, and load the kernel myself from somewhere else?
# - partitions are all 2MiB-aligned
# according to depthcharge-tools, max image size is 8 MiB, though i don't know how strict that is.
{ config, lib, pkgs, ... }:
let
  cfg = config.sane.hal.samsung;
  # sus commits:
  # - ad3e33fe071dffea07279f96dab4f3773c430fe2 (drm/panel: Move AUX B116XW03 out of panel-edp back to panel-simple)
  #   says i should switch to `edp-panel`; chrome is lying about the panel.
  #   - discussion: <https://patchwork.freedesktop.org/patch/559389/>
  #   - was tested for exynos5-peach -- which worked with the patch and uses panel_simple
  #   - snow was *not* tested, but previously used panel_edp
  linuxSourceHashes = {
    "6.2.16" = "sha256-dC5lp45tU4JgHS8VWezLM/z8C8UMxaIdj5I2DleMv8c=";  #< boots
    "6.3.13" = "sha256-bGNcuEYBHaY34OeGkqb58dXV+JF2XY3bpBtLhg634xA=";  #< boots
    "6.4.16" = "sha256-hDhelVL20AMzQeT7IDVDI35uoGEyroVPjiszO2JZzO8=";  #< boots
    "6.5.13" = "sha256-lCTwq+2RyZTIX1YQa/riHf1KCnS8dTrLlljjKAXudz4=";  #< boots
    "6.6.0-rc1" = "sha256-DRai7HhWVtRB0GiRCvCv2JM2TFKRsZ60ohD6GW0b8As=";  #< boots. upstream/torvalds' tag is `v6.6-rc1`
    "6.6.0-rc3" = "sha256-/YcuQ5UsSObqOZ0YIbcNex5HJAL8eneDDzIiTEuMDsQ=";
    "6.6.0-rc4" = "sha256-Kbv+jU2IoC4soT3ma1ZV8Un4rTQakNjut5nlA1907GQ=";  #< boots. upstream/torvalds' tag is `v6.6-rc4`
    "6.6.0-rc5" = "sha256-ia0F/W3BR+gD8qE5LEwUcJCqwBs3c5kj80DbeDzFFqY=";
    "6.6.0-rc6" = "sha256-HIrn3fkoCqVSSJ0gxY6NO8I3M8P7BD5XzQpjrhdw//s=";  #< boots. upstream/torvalds' tag is `v6.6-rc6`
    "6.6.0-rc6-bi-5188" = "sha256-TmRrPy2IhnvTVlq5bNhzsvNPgRg0qk1u2Mh3q/lBask=";  #< boots
    "6.6.0-rc6-bi-5264" = "sha256-BXt5O9hUC9lYITBO56Rzb9XJHThjt6DuiXizUi2G6/0=";  # *does not boot*. this is commit ad3e33fe071dffea07279f96dab4f3773c430fe2; actually 6.6.0-rc1, because of merge order
    "6.6.0-rc7" = "sha256-u+seQp82USt63zgMlvDRIpDmmWD2Pha5d41CorwY7f8=";  #< *does not boot*. upstream/torvalds' tag is `v6.6-rc7`
    "6.6.0" = "sha256-iUTHPMbELhtRogbrKr3n2FBwj8mbGYGacy2UgjPZZNg=";  #< *does not boot*. upstream/torvalds' tag is `v6.6`
    "6.7.12" = "sha256-6Fm7lC2bwk+wYYGeasr+6tcSw+n3VE4d9JWbc9jN6fA=";  #< *does not boot*
    "6.10.0-rc3" = "sha256-k9Mpff96xgfTyjRMn0wOQBOm7NKZ7IDtJBRYwrnccoY=";  #< *does not boot*. upstream/torvalds' tag is `v6.10-rc3`
  };
in
{
  options = {
    sane.hal.samsung.enable = lib.mkEnableOption "samsung-specific hardware support";
  };

  imports = [
    ./cross.nix
  ];

  config = lib.mkIf cfg.enable {
    boot.initrd.compressor = "gzip";
    # boot.initrd.compressorArgs = [ "--ultra" "-22" ];

    hardware.firmware = [
      (pkgs.linux-firmware.overrideAttrs (_: {
        # mwifiex_sdio seems to require uncompressed firmware (even with a kernel configured for CONFIG_MODULE_COMPRESS_ZSTD=y)
        passthru.compressFirmware = false;
      }))
    ];

    boot.initrd.availableKernelModules = [
    # boot.initrd.kernelModules = [
      # from postmarketOS
      "drm-dp-aux-bus"
      "panel-edp"
      "drm-kms-helper"
      "cros-ec-keyb"
      "sbs-battery"
      "tps65090-charger"
      "uas"
      "sd-mod"
    ];
    # N.B: mobile-nixos says these modules break udev, if builtin or run before udev:
    #  "sbs-battery"
    #  "sbs-charger"
    #  "sbs-manager"

    # boot.kernelPackages = with pkgs; linuxPackagesFor (linux_6_1.override {
    #   preferBuiltin = false;
    #   extraConfig = "";
    #   structuredExtraConfig = with lib.kernel; {
    #     SUN8I_DE2_CCU = lib.mkForce no;  #< nixpkgs' option parser gets confused on this one, somehow
    #     NET_VENDOR_MICREL = no;  #< to overcome broken KS8851_MLL (broken by nixpkgs' `extraConfig`)
    #     # KS8851_MLL = lib.mkForce module;  #< nixpkgs' option parser gets confused on this one, somehow
    #     #v XXX: required for e.g. SECURITY_LANDLOCK (specified by upstream nixpkgs) to take effect if `autoModules = false`
    #     #v seems that upstream linux (the defconfigs?), it defaults to Yes for:
    #     # - arch/x86/configs/x86_64_defconfig
    #     # - arch/arm64/configs/defconfig
    #     # but that it's left unset for e.g. arch/arm64/configs/pinephone_defconfig
    #     # SECURITY = yes;
    #   };
    # });
    # boot.kernelPackages = with pkgs; linuxPackagesFor linux_6_1;
    # boot.kernelPackages = with pkgs; linuxPackagesFor linux-exynos5-mainline;
    # boot.kernelPackages = with pkgs; linuxPackagesFor (linux-postmarketos-exynos5.override {
    #   # linux = let version = "6.6.0-rc1"; rev = "6.6.0-rc6-bi-5264"; in {
    #   #   # src = pkgs.fetchzip {
    #   #   #   url = "https://git.kernel.org/stable/t/linux-6.2.16.tar.gz";
    #   #   # };
    #   #   src = pkgs.fetchFromGitea {
    #   #     domain = "git.uninsane.org";
    #   #     owner = "colin";
    #   #     repo = "linux";
    #   #     rev = "v${rev}";
    #   #     hash = linuxSourceHashes."${rev}";
    #   #   };
    #   #   inherit version;
    #   #   modDirVersion = version;
    #   #   extraMakeFlags = [];
    #   # };
    #   # linux = linux_6_6;
    #   # linux = linux_6_8;
    #   # linux = linux_6_9;
    #   linux = linux_latest;
    #   # optimizeForSize = true;
    #   # useEdpPanel = true;
    #   revertPanelSimplePatch = true;
    # });
    # boot.kernelPackages = pkgs.linuxPackagesFor pkgs.linux-postmarketos-exynos5;
    boot.kernelPackages = pkgs.linuxPackagesFor (pkgs.linux-exynos5-mainline.override {
      kernelPatches = [
        pkgs.linux-postmarketos-exynos5.sanePatches.revertPanelSimplePatch
      ];
      structuredExtraConfig = with lib.kernel; {
        SECURITY = yes;
        SECURITY_LANDLOCK = yes;
        LSM = freeform "landlock,lockdown,yama,loadpin,safesetid,selinux,smack,tomoyo,apparmor,bpf";
      };
    });

    system.build.u-boot = pkgs.buildUBoot {
      defconfig = "snow_defconfig";
      extraMeta.platforms = [ "armv7l-linux" ];
      filesToInstall = [
        "u-boot"  #< ELF file
        "u-boot.bin"  #< raw binary, load it into RAM and jump toit
        "u-boot.cfg"  #< copy of Kconfig which this u-boot was compiled with
        "u-boot.dtb"
        "u-boot.map"
        "u-boot-nodtb.bin"
        "u-boot.sym"
      ];
      # CONFIG_BOOTCOMMAND: autoboot from usb, and fix the ordering so that it happens before the internal memory (mmc0)
      extraConfig = ''
        CONFIG_BOOTCOMMAND="env set bootcmd_usb0 \"devnum=0; run usb_boot\"; env set boot_targets \"usb0 mmc2 mmc1 mmc0\"; run distro_bootcmd"
      '';
    };

    system.build.platformPartition = pkgs.runCommand "kernel-partition" {
      preferLocalBuild = true;
      nativeBuildInputs = with pkgs; [
        vboot_reference
        dtc
        ubootTools
      ];
    } ''
      # according to depthcharge-tools, bootloader.bin is legacy, was used by the earliest
      # chromebooks (H2C) *only*.
      dd if=/dev/zero of=dummy_bootloader.bin bs=512 count=1
      echo auto > dummy_config.txt

      # from uboot snow_defconfig, also == CONFIG_SYS_LOAD_ADDR
      CONFIG_TEXT_BASE=0x43e00000

      cp ${config.system.build.u-boot}/u-boot.bin .
      ubootFlags=(
        -A arm         # architecture
        -O linux       # operating system
        -T kernel      # image type
        -C none        # compression
        -a $CONFIG_TEXT_BASE  # load address (CONFIG_TEXT_BASE)
        -e $CONFIG_TEXT_BASE  # entry point (CONFIG_SYS_LOAD_ADDR), i.e. where u-boot `bootm` should jump to to execute the kernel
        -n nixos-uboot # image name
        -d u-boot.bin  # image data
        u-boot.fit     # output
      )
      mkimage "''${ubootFlags[@]}"

      futility \
        --debug \
      vbutil_kernel \
        --version 1 \
        --bootloader ./dummy_bootloader.bin \
        --vmlinuz u-boot.fit \
        --arch arm \
        --keyblock ${pkgs.buildPackages.vboot_reference}/share/vboot/devkeys/kernel.keyblock \
        --signprivate ${pkgs.buildPackages.vboot_reference}/share/vboot/devkeys/kernel_data_key.vbprivk \
        --config ./dummy_config.txt \
        --pack $out
    '';

    # the platform partition presently only holds u-boot,
    # and it seems possibly a limitation of depthcharge that it can't launch anything > 8 MiB (?)
    # still, give a little extra room so i'm free to rearrange stuff if i find a way how.
    sane.image.platformPartSize = 256 * 1024 * 1024;

    # depthcharge firmware is designed for an A/B partition style,
    # where partition A holds a kernel and partion B holds a different kernel.
    # an update is to flash the currently inactive partition and then mark that one as active,
    # either switching the default boot from partition A to partition B, or from B to A.
    # anyway, this relies on the partitions having some extra metadata, which we add here.
    # i believe this metadata is stored in a depthcharge-specific format, not anything
    # which can be generalized.
    sane.image.installBootloader = ''
      ${lib.getExe' pkgs.buildPackages.vboot_reference "cgpt"} add ${lib.concatStringsSep " " [
        "-i 1"  # work on the first partition (instead of adding)
        "-S 1"  # mark as successful (so it'll be booted from)
        "-T 5"  # tries remaining
        "-P 10" # priority
        "$out"
      ]}
    '';
  };
}

