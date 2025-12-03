{ pkgs, ... }:
{
  hardware.bluetooth.settings.General.Experimental = true;
  hardware.bluetooth.package = pkgs.bluez.override { enableExperimental = true; };
}
