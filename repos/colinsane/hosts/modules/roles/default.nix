{ config, lib, ... }:
{
  imports = [
    ./build-machine.nix
    ./client
    ./dev-machine.nix
    ./handheld.nix
    ./pc.nix
  ];

  fileSystems."/tmp" = lib.mkIf (config.sane.roles.build-machine.enable || config.sane.roles.dev-machine) {
    device = "none";
    fsType = "tmpfs";
    options = [
      "mode=777"
      "defaults"
    ];
  };
}
