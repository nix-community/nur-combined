{ self, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../gui-common
    "${self.inputs.nixos-hardware}/common/gpu/intel"
  ];

  nix.settings.auto-optimise-store = true;

  services.sunshine.enable = true;

  services.xserver.desktopManager.kodi.enable = true;

  networking.firewall = {
    allowedTCPPorts = [ 8080 ];
    allowedUDPPorts = [ 8080 ];
  };

  networking.hostName = "atomicpi";

  system.stateVersion = "24.05";

  boot = {
    loader = {
      efi = {
        canTouchEfiVariables = false;
      };
      grub = {
        efiSupport = true;
        device = "nodev";
      };
    };
  };

  gc-hold.paths = lib.mkForce [ ];

  virtualisation.docker.enable = false;

  documentation.enable = false;
  documentation.nixos.enable = false;
  services.smartd.enable = false;
}
