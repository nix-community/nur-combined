{ pkgs, inputs, ... }:
{
  # import the nixos module
  imports = [
    inputs.noctalia.nixosModules.default
  ];
  # enable the systemd service
  services.noctalia-shell.enable = true;
}
