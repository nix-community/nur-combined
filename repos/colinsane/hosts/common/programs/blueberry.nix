{ config, lib, ... }:
let
  cfg = config.sane.programs.blueberry;
in
{
  sane.programs.blueberry = {
    sandbox.wrapperType = "inplace";  #< it places binaries in /lib and then /etc/xdg/autostart files refer to the /lib paths, and fail to be patched
    sandbox.whitelistWayland = true;
    sandbox.extraPaths = [
      "/dev/rfkill"
      "/run/dbus"
      "/sys/class/rfkill"
      "/sys/devices"
    ];
    sandbox.keepPids = true;  #< not sure why, but it fails to launch GUI without this
  };

  # TODO: hardware.bluetooth puts like 100 binaries from `bluez` onto PATH;
  # i can probably patch this so it's just `bluetoothd`.
  # see: <repo:nixos/nixpkgs:nixos/modules/services/hardware/bluetooth.nix>
  hardware.bluetooth = lib.mkIf cfg.enabled {
    enable = true;
  };
}
