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
    hardware.opengl = {
      enable = mkDefault true;
      extraPackages = with pkgs; [ intel-media-driver ];
    };

    environment.sessionVariables = {
      LIBVA_DRIVER_NAME = mkDefault "iHD";
    };
  };
}
