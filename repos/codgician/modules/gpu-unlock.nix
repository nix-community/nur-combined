# Runs gpu_unlock so the SM speed-select override is applied before the NVIDIA
# driver binds the card. Power-cycle for the first attempt; see
# https://github.com/JustAResearcher/gpu-unlock-ada for supported cards.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkOption types;
  cfg = config.hardware.gpu-unlock;
  pciAddress = types.strMatching "[0-9a-f]{4}:[0-9a-f]{2}:[0-9a-f]{2}\\.[0-7]";
  experimental = cfg.ad103Experimental || cfg.ad106Experimental;

  initrdNvidia = builtins.filter (lib.hasPrefix "nvidia") (
    config.boot.initrd.kernelModules ++ config.boot.initrd.availableKernelModules
  );
in
{
  options.hardware.gpu-unlock = {
    enable = mkEnableOption "gpu-unlock, which unlocks full-rate FP32-accumulate tensor throughput on supported NVIDIA GPUs";

    targets = mkOption {
      type = types.either (types.enum [ "all" ]) (types.nonEmptyListOf pciAddress);
      example = [ "0000:01:00.0" ];
      description = ''
        Full PCI addresses (as printed by `lspci -D`) of the cards to unlock,
        or `"all"` for every accepted unbound card. The experimental AD103 and
        AD106 targets require a single exact address.
      '';
    };

    ad103Experimental = mkEnableOption "the experimental RTX 4070 Ti SUPER (10de:2705) target";
    ad106Experimental = mkEnableOption "the experimental RTX 4060 Ti 16GB (10de:2805) target";
    rtx4090dExperimental = mkEnableOption "the experimental RTX 4090 D (10de:2685) target";

    package = mkOption {
      type = types.package;
      default = config.boot.kernelPackages.callPackage ../pkgs/gpu-unlock { };
      defaultText = lib.literalExpression "config.boot.kernelPackages.callPackage <nur-packages/pkgs/gpu-unlock> { }";
      description = "The gpu-unlock kernel module, built against `boot.kernelPackages`.";
    };

    firmwarePackage = mkOption {
      type = types.package;
      default = pkgs.callPackage ../pkgs/gpu-unlock-firmware { gpu-unlock = cfg.package; };
      defaultText = lib.literalExpression "pkgs.callPackage <nur-packages/pkgs/gpu-unlock-firmware> { gpu-unlock = config.hardware.gpu-unlock.package; }";
      description = "Firmware assets matching the gpu-unlock module's pinned hashes.";
    };

    initrd = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Load gpu_unlock in the initrd, which carries its firmware (~70 MB) into
        every initrd. Required when the initrd can load NVIDIA. Otherwise set
        false: gpu_unlock then loads early in stage 2, before udev and
        systemd-modules-load can load NVIDIA.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = experimental -> (cfg.targets != "all" && builtins.length cfg.targets == 1);
        message = "hardware.gpu-unlock: experimental AD103/AD106 targets need exactly one PCI address in `targets`.";
      }
      {
        assertion = cfg.initrd || initrdNvidia == [ ];
        message = "hardware.gpu-unlock: the initrd can load ${lib.concatStringsSep ", " initrdNvidia}; set `initrd = true` so gpu_unlock runs first.";
      }
    ];

    boot.extraModulePackages = [ cfg.package ];
    hardware.firmware = [ cfg.firmwarePackage ];

    # Load ahead of any initrd NVIDIA module. makeModulesClosure copies the
    # module's MODULE_FIRMWARE files from hardware.firmware into the initrd.
    boot.initrd.kernelModules = lib.mkIf cfg.initrd (lib.mkBefore [ "gpu_unlock" ]);

    # Stage 2 reaches NVIDIA through udev coldplug (PCI modalias) and
    # systemd-modules-load (e.g. nvidia_uvm), so run before both. Activation
    # has already pointed firmware_class at hardware.firmware. Not a softdep:
    # kmod honours only the first `softdep nvidia` line, which NixOS's NVIDIA
    # module already uses.
    systemd.services.gpu-unlock = lib.mkIf (!cfg.initrd) {
      description = "Unlock NVIDIA GPUs before their driver binds";
      unitConfig.DefaultDependencies = false;
      wantedBy = [ "sysinit.target" ];
      before = [
        "sysinit.target"
        "systemd-udevd.service"
        "systemd-udev-trigger.service"
        "systemd-modules-load.service"
      ];
      environment.MODULE_DIR = "/run/booted-system/kernel-modules/lib/modules/";
      # Only boot provides a fresh card.
      restartIfChanged = false;
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${pkgs.kmod}/bin/modprobe gpu_unlock";
      };
    };

    boot.kernelParams = [
      "gpu_unlock.targets=${if cfg.targets == "all" then "all" else lib.concatStringsSep "," cfg.targets}"
    ]
    ++ lib.optional cfg.ad103Experimental "gpu_unlock.ad103_experimental=1"
    ++ lib.optional cfg.ad106Experimental "gpu_unlock.ad106_experimental=1"
    ++ lib.optional cfg.rtx4090dExperimental "gpu_unlock.rtx4090d_experimental=1";
  };
}
