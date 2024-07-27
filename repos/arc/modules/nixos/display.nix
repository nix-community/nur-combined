{ lib, config, ... }: with lib; let
  cfg = config.hardware.display;
  primary = findFirst (mon: mon.primary) (throw "no displays configured") (attrValues cfg.monitors);
  rest = filterAttrs (_: mon: !mon.primary) cfg.monitors;
  nvidiaX11Enabled = elem "nvidia" config.services.xserver.videoDrivers;
in {
  options.hardware.display = mkOption {
    type = types.submodule ../misc/display.nix;
    default = { };
  };

  config = {
    hardware.display.nvidia.enable = mkDefault (
      (nvidiaX11Enabled && config.hardware.nvidia.modesetting.enable)
      || config.hardware.nvidia.datacenter.enable or false
    );
    services.xserver = mkIf cfg.enable {
      inherit (cfg.xserver) deviceSection screenSection serverLayoutSection;
      inherit (primary.xserver) monitorSection;
      extraConfig = mkMerge (mapAttrsToList (_: mon: mon.xserver.monitorSectionRaw) rest);
    };
  };
}
