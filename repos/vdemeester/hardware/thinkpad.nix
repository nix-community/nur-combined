{ config, pkgs, ... }:

{
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
      availableKernelModules = [ "aesni-intel" "aes_x86_64" "cryptd" ];
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
  environment.systemPackages = with pkgs; [
    linuxPackages.tp_smapi
  ];
  hardware = {
    trackpoint.enable = false;
    cpu.intel.updateMicrocode = true;
    opengl = {
      #enable = true;
      extraPackages = [ pkgs.vaapiIntel ];
      #driSupport32Bit = true;
    };
  };
  services = {
    acpid = {
      enable = true;
      lidEventCommands = ''
        if grep -q closed /proc/acpi/button/lid/LID/state; then
          date >> /tmp/i3lock.log
          DISPLAY=":0.0" XAUTHORITY=/home/fadenb/.Xauthority ${pkgs.i3lock}/bin/i3lock &>> /tmp/i3lock.log
        fi
      '';
    };
    tlp = {
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
