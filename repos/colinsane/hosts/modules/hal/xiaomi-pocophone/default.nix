# notes about qualcomm / sdm845 / Pocophone:
# - it uses QMI and QRTR internally for communication between the application processor and "everyday" peripherals like WiFi.
# - QRTR/QMI depends on a "protection domain mapper" service; this has two implementations:
#   - userspace `pd-mapper` binary. largely considered "legacy", but used by postmarketOS.
#   - kernel qcom_pd_mapper module, the upstream-native way to do this.
#   - these read firmware files (e.g. /run/current-system/firmware/*), and historically had trouble with compressed firmware.
#     and possibly have initialization order limitations for that same reason (firmware has to be available when they launch?)
#
## the bootloader responds to USB commands:
# - plug the phone into USB. you MUST use a USB-2 adapter for reliable connection.
# - boot the phone while holding power-down. it will enter android "fastboot".
# - from PC, issue `fastboot` commands:
#
### powering down the phone
# - `fastboot oem poweroff`
#   then unplug USB
{ config, lib, pkgs, ... }:
let
  cfg = config.sane.hal.xiaomi-pocophone;
  # margins for the camera cutout (top) and rounded corners in general (bot).
  # the camera cutout is literally 86 px; the rounded corners are slightly more (96 px?).
  # best scaling is likely achieved if these sum to one of:
  # - 140 = 2246 * 1/16
  # - 105 = 2246 * 3/64
  # - 123 = 2246 * 7/128
  # - 132 = 2246 * 15/256
  # - 114 = 2246 * 13/256
  # - 118 = 2246 * 27/512
  displayMarginTop = 86;
  displayMarginBot = 46;
in
{
  options = {
    sane.hal.xiaomi-pocophone.enable = lib.mkEnableOption "Xiaomi Pocophone-specific hardware support";
  };

  config = lib.mkIf cfg.enable {
    # TODO: pine64-pinephone-pro shipped a `install-u-boot` script one could invoke on a running device to update the bootloader (platform firmware);
    #       would be cool to replicate that here.
    # sane.programs.sysadminUtils.suggestedPrograms = [
    #   "ubootPocophone"
    # ];

    hardware.deviceTree.name = "qcom/sdm845-xiaomi-beryllium-tianma.dtb";
    hardware.deviceTree.overlays = [
      # {
      #   name = "sdm845-xiaomi-beryllium-mbhc";
      #   dtsFile = ./sdm845-xiaomi-beryllium-mbhc.dtso;
      # }
    ];

    # N.B.: much of this section was derived via GPT-5.6 with the goal of enabling WiFi.
    # it can probably be cleaned up with more experimentation.
    hardware.firmware = [
      # pkgs.firmware-xiaomi-beryllium
      pkgs.vanilla-mobile-nixos.pkgs.xiaomi-beryllium-firmware
    ];
    # pd-mapper and tqftpserv need to inspect/read the firmware tree too;
    # unlike the kernel firmware loader, they do not understand zstd files.
    # hardware.firmwareCompression = "none";

    # WCN3990's firmware is a Qualcomm protection-domain image. The
    # ath10k_snoc driver requests it over QRTR/TFTP; loading ath10k_snoc alone
    # is not sufficient to make wlan0 appear.
    systemd.packages = [
      # pkgs.pd-mapper
      pkgs.qrtr
      pkgs.rmtfs
      pkgs.tqftpserv
    ];
    services.udev.packages = [ pkgs.rmtfs ];
    # systemd.services.pd-mapper = {
    #   wantedBy = [ "multi-user.target" ];
    #   before = [ "rmtfs.service" ];
    # };
    systemd.services.tqftpserv = {
      wantedBy = [ "multi-user.target" ];
      before = [ "rmtfs.service" ];
    };
    # Match postmarketOS: use rmtfs' direct partition mode. The -s option
    # starts the MPSS remoteproc; -P discovers the modem partitions by label,
    # so no /var/lib/rmtfs/modem_fs* files are required.
    systemd.services.rmtfs = {
      wantedBy = [ "multi-user.target" ];
      after = [
        # "pd-mapper.service"
        "tqftpserv.service"
      ];
      requires = [
        # "pd-mapper.service"
        "tqftpserv.service"
      ];
    };
    environment.systemPackages = [ pkgs.qrtr ];
    # boot.kernelPackages = pkgs.linuxPackagesFor pkgs.linux-postmarketos-qcom-sdm845;
    boot.kernelPackages = pkgs.linuxPackagesFor pkgs.vanilla-mobile-nixos.pkgs.linuxKernels.linux_sdm845;
    boot.extraModulePackages = [ config.boot.kernelPackages.pocophone-wcd934x ];

    # options imported from vanilla-mobile-nixos
    # boot.initrd.includeDefaultModules = false;
    boot.initrd.allowMissingModules = true;

    boot.initrd.availableKernelModules = [
      "gpi"
      "i2c_qcom_geni"
      # "qcom_pd_mapper"
      "qcom_smbx" # "qcom_pmi8998_charger"  # mentioned in postmarketos, but not present in `lsmod`
      "pmi8998_fg" # "qcom_fg"  # mentioned in postmarketos and present with `lsmod`. carried in pmos tree -- see device/testing/linux-xiaomi-pipa/0002-power-supply-Add-driver-for-Qualcomm-PMIC-fuel-gauge.patch
      # "nt36xxx"  # mentioned in postmarketos, but not upstreamed and not observed to be in `lsmod` on Pocophone
      "novatek_nvt_ts"
      # "sd_mod"  # undo effects of `includeDefaultModules = false`
      # "dm_mod"
    ];

    boot.initrd.extraFirmwarePaths = [
      # pmOS explicitly puts these in the initrd: device/community/firmware-xiaomi-beryllium/firmware-initramfs.files
      "qcom/a630_sqe.fw"
      "qcom/a630_gmu.bin"
      "qcom/sdm845/Xiaomi/beryllium/a630_zap.mbn"

      # # dunno if these are required in initrd
      # "qcom/sdm845/Xiaomi/beryllium/adsp.mbn"
      # "qcom/sdm845/Xiaomi/beryllium/cdsp.mbn"
      # "qcom/sdm845/Xiaomi/beryllium/ipa_fws.mbn"
      # "qcom/sdm845/Xiaomi/beryllium/slpi.mbn"

      # # dunno if these are required in initrd
      # "ath10k/WCN3990/hw1.0/board-2.bin"
      # "ath10k/WCN3990/hw1.0/firmware-5.bin"

      # # dunno if these are required in initrd
      # "qca/crbtfw21.tlv"
      # "qca/crnv21.bin"
    ];

    boot.blacklistedKernelModules = [
      # Use the postmarketOS user-space mapper instead of the kernel mapper;
      # the two would compete for the same service-registry endpoint.
      # "qcom_pd_mapper"
      # these are likely not *all* necessary
      "fastrpc"  #< disable logspam: `qcom,fastrpc 5c00000.remote_proc:glink-edge.fastrpcglink-apps-dsp.-1.-1: rpmsg_dev_probe: failed: -22`
      "qcom_fastrpc"  #< disable logspam: `qcom,fastrpc 5c00000.remote_proc:glink-edge.fastrpcglink-apps-dsp.-1.-1: rpmsg_dev_probe: failed: -22`
      "ipa"  #< vanilla-mobile-nixos claims this causes boot lockup
    ];

    sane.programs.alsa-ucm-conf.suggestedPrograms = [
      "alsa-ucm-pocophone"
    ];

    nixpkgs.overlays = [
      (self: super: let
        maxVersion = 99;
        versions = super.lib.range 0 maxVersion;
        wlrootsName = v: if v == 0 then "wlroots" else "wlroots_0_${toString v}";
      in
        builtins.foldl' (acc: name: acc // {
          "${name}" = super."${name}".overrideAttrs (prevAttrs: {
            patches = (prevAttrs.patches or []) ++ [
              (self.replaceVars ./wlroots-display-cutout.patch {
                inherit displayMarginTop displayMarginBot;
              })
            ];
          });
        }) {} (map wlrootsName versions)
      )
    ];

    sane.programs.sway.config.extra_lines = let
      phyH = 2246.0;
      logH = phyH - displayMarginTop - displayMarginBot;
      scale = phyH / logH;
      offset = -displayMarginTop / logH;
    in lib.mkAfter ''
      # XXX(2026-08-29): Pocophone has a camera cutout + rounded corners;
      # we truncate & scale the display at a lower layer (wlroots) to avoid those:
      # touchscreen needs that same transform.
      input "0:0:nt36672a-ts" calibration_matrix 1 0 0 0 ${toString scale} ${toString offset}
    '';
  };
}
