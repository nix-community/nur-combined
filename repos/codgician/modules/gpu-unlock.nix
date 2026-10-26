# Runs gpu_unlock from the initrd so the SM speed-select override is applied
# before the NVIDIA driver binds the card. Power-cycle for the first attempt;
# see https://github.com/JustAResearcher/gpu-unlock-ada for supported cards.
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
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = experimental -> (cfg.targets != "all" && builtins.length cfg.targets == 1);
        message = "hardware.gpu-unlock: experimental AD103/AD106 targets need exactly one PCI address in `targets`.";
      }
    ];

    boot.extraModulePackages = [ cfg.package ];
    # Load ahead of any initrd NVIDIA module. makeModulesClosure copies the
    # module's MODULE_FIRMWARE files from hardware.firmware into the initrd.
    boot.initrd.kernelModules = lib.mkBefore [ "gpu_unlock" ];
    hardware.firmware = [ cfg.firmwarePackage ];

    boot.kernelParams = [
      "gpu_unlock.targets=${if cfg.targets == "all" then "all" else lib.concatStringsSep "," cfg.targets}"
    ]
    ++ lib.optional cfg.ad103Experimental "gpu_unlock.ad103_experimental=1"
    ++ lib.optional cfg.ad106Experimental "gpu_unlock.ad106_experimental=1"
    ++ lib.optional cfg.rtx4090dExperimental "gpu_unlock.rtx4090d_experimental=1";
  };
}
