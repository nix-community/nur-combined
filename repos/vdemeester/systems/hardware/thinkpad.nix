{ config, pkgs, ... }:
let
  sources = import ../../nix/sources.nix;
in
{
  imports = [ (sources.nixos-hardware + "/lenovo/thinkpad") ];
  boot = {
    blacklistedKernelModules = [
      # Kernel GPU Savings Options (NOTE i915 chipset only)
      "sierra_net"
      "cdc_mbim"
      "cdc_ncm"
    ];
    extraModprobeConfig = ''
      options snd_hda_intel power_save=1
    '';
    initrd = {
      availableKernelModules = [ "ehci_pci" "ahci" "xhci_pci" "usb_storage" "sd_mod" "sdhci_pci" "aesni-intel" "aes_x86_64" "cryptd" ];
    };
    kernelModules = [ "kvm_intel" ];
    kernelParams = [
      # Kernel GPU Savings Options (NOTE i915 chipset only)
      "i915.enable_rc6=1"
      "i915.enable_fbc=1"
      "i915.lvds_use_ssc=0"
      "drm.debug=0"
      "drm.vblankoffdelay=1"
      "kvm_intel.nested=1"
      "intel_iommu=on"
    ];
    loader.efi.canTouchEfiVariables = true;
  };
  hardware = {
    trackpoint.enable = false;
    cpu.intel.updateMicrocode = true;
  };
  services = {
    acpid = {
      enable = true;
    };
    xserver = {
      synaptics.enable = false;
      config =
        ''
          Section "InputClass"
            Identifier     "Enable libinput for TrackPoint"
            MatchIsPointer "on"
            Driver         "libinput"
            Option         "ScrollMethod" "button"
            Option         "ScrollButton" "8"
          EndSection
        '';
      inputClassSections = [
        ''
          Identifier "evdev touchpad off"
          MatchIsTouchpad "on"
          MatchDevicePath "/dev/input/event*"
          Driver "evdev"
          Option "Ignore" "true"
        ''
      ];
    };
  };
}
