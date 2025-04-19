_:
{ config, lib, modulesPath, pkgs, ... }:

{
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
      ./disko.nix
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

  fileSystems."/data" =
    {
      device = "/dev/disk/by-uuid/13ad50f4-8269-43a5-9fb9-adb1919a5f3c";
      fsType = "btrfs";
    };

  services.fstrim.enable = true;

  swapDevices = [ ];

  fileSystems."/persist".neededForBoot = true;
  fileSystems."/etc/ssh" = {
    depends = [ "/persist" ];
    neededForBoot = true;
  };
  environment.persistence."/persist" = {
    directories = [
      "/etc/ssh"
      "/var"
    ];
    files = [
      "/etc/machine-id"
    ];
    users.nixos = {
      directories = [
        ".cache"
        ".cmake"
        ".config"
        ".local"
        ".mozilla"
        ".nali"
        ".pki"
        ".ssh"
        "repos"
      ];
    };
  };

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  # networking.useDHCP = lib.mkDefault true;
  networking.interfaces.enp5s0.useDHCP = lib.mkDefault true;

  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  hardware.logitech.wireless = {
    enable = true;
    enableGraphical = true;
  };

  environment.variables = {
    ROC_ENABLE_PRE_VEGA = "1";
  };
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      amdvlk
      rocmPackages_5.clr.icd
      rocmPackages_5.clr
      rocmPackages_5.rocminfo
      rocmPackages_5.rocm-runtime
    ];
    extraPackages32 = with pkgs; [
      driversi686Linux.amdvlk
    ];
  };

  environment.systemPackages = with pkgs; [
    clinfo
  ];

  systemd.tmpfiles.rules =
    let
      rocmEnv = pkgs.symlinkJoin {
        name = "rocm-combined";
        paths = with pkgs.rocmPackages_5; [
          rocblas
          hipblas
          clr
        ];
      };
    in
    [
      "L+    /opt/rocm   -    -    -     -    ${rocmEnv}"
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

  services.udev.extraRules = lib.strings.concatStringsSep ", " [
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
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
