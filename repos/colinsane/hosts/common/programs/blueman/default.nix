{ config, lib, ... }:
let
  cfg = config.sane.programs.blueman;
in
{
  sane.programs.blueman = {
    sandbox.method = null;  #< TODO: sandbox
  };

  # TODO: hardware.bluetooth puts like 100 binaries from `bluez` onto PATH;
  # i can probably patch this so it's just `bluetoothd`.
  # see: <repo:nixos/nixpkgs:nixos/modules/services/hardware/bluetooth.nix>
  hardware.bluetooth = lib.mkIf cfg.enabled {
    enable = true;
  };
}
