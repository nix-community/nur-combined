{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.hardware;
  any' = l: any (x: x == config.networking.hostName) l;
  laptop = any' [ "suitecase" ];
  server = any' [ "robocat" ];
  desktop = any' [ "powerhorse" ];
  builder = {
    nix.buildMachines = [{
      hostName = "powerhorse";
      systems = [ "x86_64-linux" "i686-linux" ];
      supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
      maxJobs = 4;
    }];
    nix.distributedBuilds = true;
    nix.extraOptions = ''
      builders-use-substitutes = true
    '';
  };
in {
  options.services.hardware = {
    enable = mkEnableOption ''
      Hardware tweaks for different hosts
    '';
    user = mkOption {
      type = types.str;
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      services.fstrim.enable = true;
      boot.kernel.sysctl."vm.swappiness" = 1;
      boot.loader.systemd-boot.enable = true;
    })
    (mkIf (cfg.enable && server) ({
      systemd.watchdog.runtimeTime = "30s";
      systemd.watchdog.rebootTime = "10m";
      systemd.watchdog.kexecTime = "10m";
      services.udev.extraRules = ''
        ACTION=="add", SUBSYSTEM=="block", KERNEL=="sd[a-z]", ENV{ID_SERIAL_SHORT}=="WD-WXS2E902C67R", RUN+="${getExe pkgs.hdparm} -B 254 /dev/%k"
        ACTION=="add", SUBSYSTEM=="block", KERNEL=="sd[a-z]", ENV{ID_SERIAL_SHORT}=="WWD1JS70", RUN+="${getExe pkgs.hdparm} -S 242 /dev/%k"
      '';
      boot.kernelParams = [
        "console=tty1"
        "console=ttyS0,115200"
      ];
    } // builder))
    (mkIf (cfg.enable && laptop) ({
      hardware.bluetooth.enable = true;
      hardware.bluetooth.powerOnBoot = false;
      services.upower = {
        enable = true;
        percentageLow = 7;
        percentageCritical = 6;
        percentageAction = 5;
        criticalPowerAction = "Hibernate";
      };
      services.logind.powerKey = "hibernate";
      programs.light.enable = true;
      users.users.${cfg.user}.extraGroups = [ "video" ];
      services.tlp.enable = true;
      hardware.graphics.extraPackages = [ pkgs.vaapiIntel ];
      # https://github.com/NixOS/nixpkgs/issues/270809
      systemd.services.ModemManager.wantedBy = [ "multi-user.target" "network.target" ];
    } // builder))
    (mkIf (cfg.enable && desktop) {
      nix.settings.cores = 8;
      nix.settings.trusted-users = [ cfg.user ];
      hardware.bluetooth.enable = true;
      hardware.bluetooth.powerOnBoot = false;
      services.logind.powerKey = "suspend";
      boot.extraModulePackages = [ config.boot.kernelPackages.ddcci-driver ];
      boot.kernelModules = [ "i2c-dev" "ddcci_backlight" ];
      programs.light.enable = true;
      users.users.${cfg.user}.extraGroups = [ "video" ];
      boot.initrd.kernelModules = [ "amdgpu" ];
      services.udev.extraRules = ''
        ACTION=="add", ATTRS{idVendor}=="1a2c", ATTRS{idProduct}=="2c27", ATTR{power/wakeup}="disabled"
      '';
    })
  ];
}
