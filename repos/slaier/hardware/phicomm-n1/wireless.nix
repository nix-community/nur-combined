{ config, lib, pkgs, ... }:

let
  cfg = config.hardware.phicomm-n1.wireless;
in
{
  imports = [
    ./dtos.nix
  ];

  options.hardware.phicomm-n1.wireless = with lib; {
    enable = mkEnableOption "Whether to enable wireless driver and firmware.";
  };

  config = lib.mkMerge [
    {
      hardware.enableRedistributableFirmware = lib.mkOverride 999 false;
    }
    (lib.mkIf cfg.enable {
      networking.wireless.enable = true;
      networking.wireless.userControlled.enable = lib.mkDefault true;
      hardware.wirelessRegulatoryDatabase = true;
      hardware.firmware = with pkgs; [
        (runCommand "wireless-firmware-n1" { } ''
          mkdir -p $out
          cd ${raspberrypiWirelessFirmware}
          cp --no-preserve=mode -t $out --parents lib/firmware/brcm/brcmfmac43455-sdio.{bin,clm_blob,txt}
          cd $out/lib/firmware/brcm
          ln -s brcmfmac43455-sdio.{,'phicomm,n1.'}bin
        '')
      ];
    })
    (lib.mkIf (!cfg.enable) {
      networking.wireless.enable = false;
      hardware.phicomm-n1.dtos = [
        ''
          target = <&sd_emmc_a>;

          __overlay__ {
            status = "disabled";
          };
        ''
      ];
    })
  ];
}
