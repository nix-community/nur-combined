{
  config,
  lib,
  ...
}:
let
  cfg = config.hardware.gpu-unlock;
  # Same kernel as nvidia. Firmware is shared across kernel versions.
  gpuUnlock = config.boot.kernelPackages.gpu-unlock;
in
{
  options.hardware.gpu-unlock = {
    enable = lib.mkEnableOption "gpu-unlock before the NVIDIA driver binds";

    targets = lib.mkOption {
      type = lib.types.str;
      default = "all";
      example = "0000:01:00.0";
      description = ''
        `gpu_unlock.targets` kernel parameter.
        `all`, or comma-separated PCI addresses as printed by `lspci -D`.
        The module loads either way and does nothing when this is empty.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    boot.extraModulePackages = [ gpuUnlock ];
    # nvidia is loaded from the root filesystem. This has to run in the
    # initrd, while the card is still unbound, or the unlock is skipped.
    boot.initrd.kernelModules = lib.mkBefore [ "gpu_unlock" ];
    boot.kernelParams = [ "gpu_unlock.targets=${cfg.targets}" ];
    hardware.firmware = [ gpuUnlock.firmware ];
  };
}
