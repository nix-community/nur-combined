{
  flake.modules.nixos.space-opt =
    { lib, ... }:
    {
      config = {
        nix.enable = false;
        nix.registry = lib.mkForce { };
        nix.nixPath = lib.mkForce [ ];

        services.lvm.enable = false;
        security.sudo.enable = false;
        nix.gc.automatic = lib.mkForce false;

        hardware.enableRedistributableFirmware = lib.mkForce false;
        hardware.enableAllFirmware = lib.mkForce false;
        hardware.firmware = lib.mkForce [ ];

        environment.defaultPackages = lib.mkForce [ ];
      };
    };
}
