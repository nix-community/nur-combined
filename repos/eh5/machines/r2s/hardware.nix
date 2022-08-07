{ config, pkgs, lib, ... }: {
  hardware.deviceTree.name = "rockchip/rk3328-nanopi-r2s.dtb";
  # hardware.deviceTree.filter = "*rk3328-nanopi-r2s.dtb";
  # hardware.deviceTree.overlays = [{
  #   name = "sysled";
  #   dtsFile = ./files/sysled.dts;
  # }];

  # nanopi r2s's DTS has not been actively updated, so just use the prebuilt one to avoid rebuild
  hardware.deviceTree.package = pkgs.lib.mkForce (
    pkgs.runCommand "dtbs-nanopi-r2s" { } ''
      install -TDm644 ${./files/rk3328-nanopi-r2s.dtb} $out/rockchip/rk3328-nanopi-r2s.dtb
    ''
  );

  hardware.firmware = [
    (pkgs.runCommand
      "linux-firmware-r8152"
      { }
      "install -TDm644 ${./files/rtl8153a-4.fw} $out/lib/firmware/rtl_nic/rtl8153a-4.fw"
    )
  ];

  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-label/NIXOS_BOOT";
      fsType = "ext4";
    };
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "f2fs";
      options = [ "compress_algorithm=zstd:6" "compress_chksum" "atgc" "gc_merge" "lazytime" ];
    };
  };

  boot = {
    loader = {
      timeout = 0;
      grub.enable = false;
      generic-extlinux-compatible = {
        enable = true;
        configurationLimit = 0;
      };
    };
    kernelPackages = pkgs.linuxKernel.packages.linux_5_18;
    kernelParams = [
      "console=ttyS2,1500000"
      "earlycon=uart8250,mmio32,0xff130000"
      "mitigations=off"
    ];
    initrd = {
      includeDefaultModules = false;
      kernelModules = [ "ledtrig-netdev" ];
    };
    blacklistedKernelModules = [ "hantro_vpu" "drm" "lima" "videodev" ];
    kernelModules = [ "ledtrig-netdev" ];
    tmpOnTmpfs = true;
  };

  boot.kernel.sysctl = {
    "vm.vfs_cache_pressure" = 10;
    "vm.dirty_ratio" = 50;
    "vm.swappiness" = 20;
  };

  powerManagement.cpuFreqGovernor = "schedutil";

  services.fake-hwclock.enable = true;
  services.chrony.enable = true;
  networking.timeServers = [
    "ntp.aliyun.com"
    "ntp1.aliyun.com"
    "ntp2.aliyun.com"
    "ntp3.aliyun.com"
    "ntp4.aliyun.com"
    "ntp5.aliyun.com"
    "ntp6.aliyun.com"
    "ntp7.aliyun.com"
  ];

  systemd.services."setup-net-leds" = {
    description = "Setup network LEDs";
    unitConfig = { DefaultDependencies = "no"; };
    serviceConfig = { Type = "simple"; };
    wantedBy = [ "sysinit.target" ];
    script = ''
      cd /sys/class/leds/nanopi-r2s:green:lan
      echo netdev > trigger
      echo 1 | tee link tx rx >/dev/null
      echo intern0 > device_name

      cd /sys/class/leds/nanopi-r2s:green:wan
      echo netdev > trigger
      echo 1 | tee link tx rx >/dev/null
      echo extern0 > device_name
    '';
  };
  systemd.services."setup-sys-led" = {
    description = "Setup booted LED";
    serviceConfig = { Type = "idle"; };
    wantedBy = [ "multi-user.target" ];
    script = ''
      echo default-on > /sys/class/leds/nanopi-r2s:red:sys/trigger
    '';
  };
}
