{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.hardware;
  any' = l: any (x: x == config.networking.hostName) l;
  laptop = any' [ "suitecase" ];
  server = any' [ "robocat" ];
  desktop = any' [ "powerhorse" ];
  ip4 = pkgs.nur.repos.dukzcry.lib.ip4;
  builder = {
    nix.buildMachines = [{
      hostName = "powerhorse";
      systems = [ "x86_64-linux" "i686-linux" ];
      supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
      maxJobs = 4;
    }];
    nix.distributedBuilds = true;
    nix.settings.substituters = [ "http://powerhorse:5000" ];
    nix.settings.trusted-public-keys = [ "powerhorse-1:d6cps6qy6UuAaTquP0RwSePLhrmzz9xFjk+rVlmP2sY=" ];
    nix.extraOptions = ''
      builders-use-substitutes = true
      # https://github.com/NixOS/nix/issues/3514
      fallback = true
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
      powerManagement.cpuFreqGovernor = lib.mkDefault "schedutil";
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
      services.logind.extraConfig = ''
        HandlePowerKey=hibernate
      '';
      programs.light.enable = true;
      users.users.${cfg.user}.extraGroups = [ "video" ];
      boot.kernelParams = [ "mitigations=off" ];
      services.tlp.enable = true;
      hardware.opengl.extraPackages = [ pkgs.vaapiIntel ];
    } // builder))
    (mkIf (cfg.enable && desktop) {
      services.nix-serve = {
        enable = true;
        secretKeyFile = "/var/cache-priv-key.pem";
      };
      nix.settings.cores = 8;
      nix.settings.trusted-users = [ cfg.user ];
      hardware.bluetooth.enable = true;
      hardware.bluetooth.powerOnBoot = false;
      powerManagement.cpuFreqGovernor = lib.mkDefault "schedutil";
      services.logind.extraConfig = ''
        HandlePowerKey=suspend
      '';
      boot.extraModulePackages = [ config.boot.kernelPackages.ddcci-driver ];
      boot.kernelModules = [ "i2c-dev" "ddcci_backlight" ];
      programs.light.enable = true;
      users.users.${cfg.user}.extraGroups = [ "video" ];
      boot.initrd.kernelModules = [ "amdgpu" ];
    })
  ];
}
