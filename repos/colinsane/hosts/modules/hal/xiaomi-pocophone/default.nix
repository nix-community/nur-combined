{ config, lib, pkgs, ... }:
let
  cfg = config.sane.hal.xiaomi-pocophone;
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

    boot.kernelPackages = pkgs.linuxPackagesFor pkgs.linux-postmarketos-qcom-sdm845;

    # TODO: enable systemd-boot, but needs linux-postmarketos-qcom-sdm845.features.efiBootStub == true.
    boot.loader.generic-extlinux-compatible.enable = true;
    boot.loader.systemd-boot.enable = false;

    boot.initrd.availableKernelModules = [
      "gpi"
      "i2c_qcom_geni"
      "qcom_smbx" # "qcom_pmi8998_charger"  # mentioned in postmarketos, but not present in `lsmod`
      "pmi8998_fg" # "qcom_fg"  # mentioned in postmarketos and present with `lsmod`. carried in pmos tree -- see device/testing/linux-xiaomi-pipa/0002-power-supply-Add-driver-for-Qualcomm-PMIC-fuel-gauge.patch
      # "nt36xxx"  # mentioned in postmarketos, but not upstreamed and not observed to be in `lsmod` on Pocophone
      "novatek_nvt_ts"
    ];
  };
}
