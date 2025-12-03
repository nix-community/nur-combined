{ config, lib, pkgs, ... }:
let
  cfg = config.sane.hal.x86_64;
in
{
  options = {
    sane.hal.x86_64.enable = (lib.mkEnableOption "x86_64-specific hardware support") // {
      default = pkgs.stdenv.hostPlatform.system == "x86_64-linux";
    };
  };
  config = lib.mkIf cfg.enable {
    # boot.initrd.availableKernelModules = [
    #   "xhci_pci" "ahci" "sd_mod" "sdhci_pci"  # nixos-generate-config defaults
    #   "usb_storage"   # rpi needed this to boot from usb storage, i think.
    #   "nvme"  # to boot from nvme devices
    #   # efi_pstore evivars

    #   # added (speculatively) 2024/05/21; these were implicitly being added by nixos/modules/system/boot/kernel.nix
    #   # i've copied not all of them, but most
    #   "mmc_block"
    #   "dm_mod"
    #   # USB keyboards
    #   "uhci_hcd" "ehci_hcd" "ehci_pci" "ohci_hcd" "ohci_pci" "xhci_hcd" "xhci_pci" "usbhid" "hid_generic" "hid_lenovo" "hid_apple" "hid_roccat" "hid_logitech_hidpp" "hid_logitech_dj" "hid_microsoft" "hid_cherry" "hid_corsair"
    #   # x86 keyboard stuff
    #   "pcips2" "atkbd" "i8042"
    #   # stage-2 init needs rtc?
    #   "rtc_cmos"
    # ];

    hardware.cpu.amd.updateMicrocode = true;    # desko
    hardware.cpu.intel.updateMicrocode = true;  # flowy, lappy

    boot.extraModprobeConfig = ''
      # allow nested virtualization. XXX(2025-06-24): required for my work (?)
      # see: <https://wiki.nixos.org/wiki/Libvirt#Nested_virtualization>
      # see: <https://www.linux-kvm.org/page/Nested_Guests>
      options kvm_amd nested=1
      options kvm_intel nested=1
    '';
  };
}
