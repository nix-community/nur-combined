{
  config,
  pkgs,
  lib,
  ...
}:
{
  hardware.deviceTree.name = "rockchip/rk3328-nanopi-r2s.dtb";
  # hardware.deviceTree.filter = "*rk3328-nanopi-r2s.dtb";
  # hardware.deviceTree.overlays = [{
  #   name = "sysled";
  #   dtsFile = ./files/sysled.dts;
  # }];

  # NanoPi R2S's DTS has not been actively updated, so just use the prebuilt one to avoid rebuilding
  hardware.deviceTree.package = pkgs.lib.mkForce (
    pkgs.runCommand "dtbs-nanopi-r2s" { } ''
      install -TDm644 ${./files/rk3328-nanopi-r2s.dtb} $out/rockchip/rk3328-nanopi-r2s.dtb
    ''
  );

  hardware.firmware = [
    (pkgs.runCommand "linux-firmware-r8152" { } ''
      install -TDm644 ${./files/rtl8153b-2.fw} $out/lib/firmware/rtl_nic/rtl8153b-2.fw
    '')
  ];

  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-label/NIXOS_BOOT";
      fsType = "ext4";
    };
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "f2fs";
      options = [
        "compress_algorithm=zstd:6"
        "compress_chksum"
        "atgc"
        "gc_merge"
        "lazytime"
      ];
    };
  };

  boot = {
    loader = {
      timeout = 1;
      grub.enable = false;
      generic-extlinux-compatible = {
        enable = true;
        configurationLimit = 15;
      };
    };
    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [
      "console=ttyS2,1500000"
      "earlycon=uart8250,mmio32,0xff130000"
      "mitigations=off"
    ];
    blacklistedKernelModules = [
      "hantro_vpu"
      "drm"
      "lima"
      "rockchip_vdec"
    ];
    tmp.useTmpfs = true;
  };

  boot.initrd = {
    includeDefaultModules = false;
    kernelModules = [ "mmc_block" ];
    extraUtilsCommands = ''
      copy_bin_and_libs ${pkgs.haveged}/bin/haveged
    '';
    extraUtilsCommandsTest = ''
      $out/bin/haveged --version
    '';
    # provide entropy with haveged in stage 1 for faster crng init
    preLVMCommands = lib.mkBefore ''
      haveged --once
      # I don't need LVM
      alias lvm=true
    '';
  };

  boot.kernel.sysctl = {
    "vm.vfs_cache_pressure" = 10;
    "vm.dirty_ratio" = 50;
    "vm.swappiness" = 20;
  };

  powerManagement.cpuFreqGovernor = "schedutil";

  services.udev.extraRules =
    ''ACTION=="add" SUBSYSTEM=="usb", ATTRS{idVendor}=="0bda", ATTRS{idProduct}=="8153", ''
    + ''RUN+="${pkgs.rtl8152-led-ctrl}/bin/rtl8152-led-ctrl set --device %s{busnum}:%s{devnum}"'';

  services.lvm.enable = false;

  systemd.services."wait-system-running" = {
    description = "Wait system running";
    serviceConfig = {
      Type = "simple";
    };
    script = ''
      systemctl is-system-running --wait
    '';
  };

  systemd.services."setup-net-leds" = {
    description = "Setup network LEDs";
    serviceConfig = {
      Type = "simple";
    };
    wantedBy = [ "multi-user.target" ];
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    script = ''
      # Update: fixed since latest stable kernels, see
      # <https://github.com/torvalds/linux/compare/adec57ff8e66aee632f3dd1f93787c13d112b7a1...4ea4d4808e342ddf89ba24b93ffa2057005aaced>
      # Somehow Linux kernel has not set gpio2-15(b7) conntecting LAN LED to "GPIO" pinmux, causing no output to LAN LED,
      # workaround it by setting pinmux register(GRF_GPIO2CL_IOMUX) manually.
      #
      # Refer to gpio2_b7_sel under GRF_GPIO2CL_IOMUX in
      # <https://opensource.rock-chips.com/images/9/97/Rockchip_RK3328TRM_V1.1-Part1-20170321.pdf>
      #
      # 0xff100028 = 0xff100000(base address of GRF) + 0x28(offset of register GRF_GPIO2CL_IOMUX)
      # 0x00070000 = 0x0007 << 16 (write mask of bits 2:0) + 0x0000 (set gpio2_b7_sel bits 2:0 to 0, i.e. "GPIO" MUX)
      #${pkgs.busybox}/bin/devmem 0xff100028 32 0x00070000

      ${pkgs.kmod}/bin/modprobe ledtrig_netdev
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
    requires = [ "wait-system-running.service" ];
    after = [ "wait-system-running.service" ];
    wantedBy = [ "multi-user.target" ];
    script = ''
      echo default-on > /sys/class/leds/nanopi-r2s:red:sys/trigger
    '';
  };
}
