{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
{
  options.eownerdead.intelGraphics = mkEnableOption "Recommended option for Intel Graphics";

  config = mkIf config.eownerdead.intelGraphics {
    boot.kernelParams = [
      "i915.force_probe=!9a49"
      "xe.force_probe=9a49"
    ];
    hardware.graphics = {
      enable = mkDefault true;
      extraPackages = with pkgs; [
        intel-media-driver
        intel-compute-runtime-legacy1
      ];
    };

    environment.sessionVariables = {
      LIBVA_DRIVER_NAME = mkDefault "iHD";
    };
  };
}
