{ config, lib, ... }:
let
  cfg = config.sane.programs.eg25-manager;
in
{
  sane.programs.eg25-manager = {
    # it has to be enabled system-wide for its udev rules to make it into /run/current-system/sw/lib/udev/rules.d.
    enableFor.system = lib.mkIf (builtins.any (en: en) (builtins.attrValues cfg.enableFor.user)) true;
  };

  # not sure if this is required or if it's enough that eg25-manager is on system.packages.
  services.udev.packages = lib.mkIf cfg.enabled [ cfg.package ];
}
