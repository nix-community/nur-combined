{ inputs, lib, ... }:
{
  # nix run .#alpha (Linux; x86_64 hosts emulate the ARM guest).
  # Keep Alpha's users and services, replacing only the physical Pi hardware.
  disabledModules = [ ./hardware.nix ];
  networking.networkmanager.enable = lib.mkForce false;

  virtualisation = {
    # Run the aarch64 guest under QEMU on an x86_64 Linux development machine.
    host.pkgs = lib.mkDefault inputs.nixpkgs.legacyPackages.x86_64-linux;
    graphics = false;
    memorySize = 1024;
    cores = 4;
    forwardPorts = [
      {
        from = "host";
        host.address = "127.0.0.1";
        host.port = 23939;
        guest.port = 3939;
      }
    ];
  };
}
