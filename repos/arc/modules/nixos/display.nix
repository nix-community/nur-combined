{ lib, config, ... }: with lib; let
  cfg = config.hardware.display;
  primary = findFirst (mon: mon.primary) (throw "no displays configured") (attrValues cfg.monitors);
  rest = filterAttrs (_: mon: !mon.primary) cfg.monitors;
in {
  options.hardware.display = mkOption {
    type = types.submodule ../misc/display.nix;
    default = { };
  };

  config = {
    hardware.display.nvidia.enable = mkDefault config.hardware.nvidia.modesetting.enable;
    services.xserver = mkIf cfg.enable {
      inherit (cfg.xserver) deviceSection screenSection serverLayoutSection;
      inherit (primary.xserver) monitorSection;
      extraConfig = mkMerge (mapAttrsToList (_: mon: mon.xserver.monitorSectionRaw) rest);
    };
  };
}
