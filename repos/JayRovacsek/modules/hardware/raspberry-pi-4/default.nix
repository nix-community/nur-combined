{ config, pkgs, ... }: {
  hardware = {
    # Required for the Wireless firmware
    enableRedistributableFirmware = true;

    deviceTree.filter = "bcm2711-rpi-*.dtb";

    raspberry-pi."4" = {
      # Enable GPU acceleration
      fkms-3d = {
        enable = true;
        cma = 1024;
      };
      audio.enable = true;
      dwc2.enable = false;
      poe-hat.enable = false;
      pwm0.enable = false;
      tc358743.enable = false;
    };

    pulseaudio = {
      enable = true;
      package = pkgs.pulseaudioFull;
      # Default to the 3.5mm jack as output
      extraConfig = ''
        set-default-sink alsa_output.platform-bcm2835_audio.stereo-fallback.2
      '';
    };
  };

  boot = {
    kernelPackages = pkgs.linuxPackages_rpi4;
    cleanTmpDir = true;
    extraModprobeConfig = ''
      options snd_bcm2835 enable_headphones=1
    '';
    tmpOnTmpfs = true;
    initrd.availableKernelModules = [ "usbhid" "usb_storage" ];
    # ttyAMA0 is the serial console broken out to the GPIO
    kernelParams =
      [ "8250.nr_uarts=1" "console=ttyAMA0,115200" "console=tty1" "cma=128M" ];

    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };
  };
}
