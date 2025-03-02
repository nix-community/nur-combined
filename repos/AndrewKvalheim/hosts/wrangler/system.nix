{ ... }:

{
  imports = [
    ../../common/system.nix
    <nixos-hardware/lenovo/thinkpad/t14/amd/gen2>
    /etc/nixos/hardware-configuration.nix
    ./local/system.nix
  ];

  # Host parameters
  host = {
    name = "wrangler";
    local = ./local;
    resources = ./resources;
  };

  # Hardware
  services.kmonad.keyboards.default.device = "/dev/input/by-path/platform-i8042-serio-0-event-kbd";

  # Nix
  system.stateVersion = "22.05"; # Permanent

  # Mouse
  services.input-remapper.enable = true;

  # Networking
  systemd.network.links = {
    "10-wifi".linkConfig.Name = "wifi";
  };
}
