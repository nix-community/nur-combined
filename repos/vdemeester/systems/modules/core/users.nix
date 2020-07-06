{ config, ... }:
{
  users.motd = with config; ''
    Welcome to ${networking.hostName}

    - This machine is managed by NixOS
    - All changes are futile

    OS:      Nixos ${system.nixos.release} (${system.nixos.codeName})
    Version: ${system.nixos.version}
    Kernel:  ${boot.kernelPackages.kernel.version}
  '';
}
