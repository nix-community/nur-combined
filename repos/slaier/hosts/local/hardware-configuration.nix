{ config, lib, modulesPath, pkgs, ... }:
{
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
      ./filesystem.nix
    ];

  boot.tmp.cleanOnBoot = true;
  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "it87" "kvm-amd" ];
  boot.extraModulePackages = with config.boot.kernelPackages; [ it87 ];
  boot.extraModprobeConfig = ''
    options it87 ignore_resource_conflict=1
  '';
  boot.kernelParams = [
    "iommu=pt"
    "amdgpu.ppfeaturemask=0xfffd7fff"
    "zswap.enabled=1"
  ];

  services.fstrim.enable = true;

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = false;
  networking.interfaces.enp5s0.useDHCP = lib.mkDefault true;

  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  hardware.logitech.wireless = {
    enable = true;
    enableGraphical = true;
  };

  nixpkgs.overlays = [
    (_final: prev: {
      rocmPackages = prev.rocmPackages.overrideScope (
        _final: prev: {
          clr = (prev.clr.override {
            localGpuTargets = [ "gfx803" ];
          }).overrideAttrs (prev: {
            patches = prev.patches ++ [ ./clr.patch ];
          });
        }
      );
    })
  ];

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      amdvlk
      rocmPackages.clr.icd
    ];
  };

  environment.systemPackages = with pkgs; [
    amdgpu_top
    clinfo
  ];

  hardware.fancontrol =
    let
      gpu = "/sys/devices/pci0000:00/0000:00:03.1/0000:07:00.0/hwmon/hwmon[[:print:]]*";
    in
    {
      enable = true;
      config = ''
        INTERVAL=4
        FCTEMPS=${gpu}/pwm1=${gpu}/temp1_input
        FCFANS=${gpu}/pwm1=${gpu}/fan1_input
        MINTEMP=${gpu}/pwm1=55
        MAXTEMP=${gpu}/pwm1=65
        MINSTART=${gpu}/pwm1=75
        MINSTOP=${gpu}/pwm1=0
        MAXPWM=${gpu}/pwm1=155
      '';
    };

  services.udev.extraRules = ''
    ${lib.strings.concatStringsSep ", " [
      ''ACTION=="add"''
      ''SUBSYSTEM=="hwmon"''
      ''ATTR{name}=="amdgpu"''
      ''ATTRS{power_dpm_force_performance_level}=="auto"''
      ''ATTR{power1_cap}="172000000"''
      ''RUN+="${pkgs.writeShellScript "sysfs-reload" ''
        set -o errexit
        cd $1
        [[ -e power_dpm_force_performance_level ]]
        [[ -e pp_od_clk_voltage ]]
        echo "manual" > power_dpm_force_performance_level
        echo "s 0 300 750" > pp_od_clk_voltage
        echo "s 1 845 750" > pp_od_clk_voltage
        echo "s 2 1055 800" > pp_od_clk_voltage
        echo "s 3 1175 900" > pp_od_clk_voltage
        echo "s 4 1270 900" > pp_od_clk_voltage
        echo "s 5 1330 900" > pp_od_clk_voltage
        echo "s 6 1385 950" > pp_od_clk_voltage
        echo "s 7 1450 1000" > pp_od_clk_voltage
        echo "c" > pp_od_clk_voltage
      ''} %S%p/device"''
    ]}
    SUBSYSTEM=="tty", ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="55d3", SYMLINK+="tty_nano_esp32c6", MODE="0666"
    SUBSYSTEM=="tty", ATTRS{idVendor}=="303a", ATTRS{idProduct}=="1001", SYMLINK+="tty_xiao_esp32c6", MODE="0666"
  '';

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
