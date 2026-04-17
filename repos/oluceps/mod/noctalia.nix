{ inputs, ... }:
{
  flake.modules.nixos.noctalia = {
    imports = [
      inputs.noctalia.nixosModules.default
    ];
    # enable the systemd service
    services.noctalia-shell.enable = true;
  };
}
