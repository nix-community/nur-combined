{ config, lib, ... }:
{
  services.fwupd = lib.mkIf config.sane.programs.fwupd.enabled {
    # enables the dbus service, which i think the frontend speaks to.
    enable = true;
  };
}
