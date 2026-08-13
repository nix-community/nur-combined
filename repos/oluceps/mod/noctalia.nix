{ inputs, ... }:
{

  flake.modules.nixos.noctalia = {
    # hjem = {
    #   extraModules = [
    #     inputs.noctalia.hjemModules.default
    #   ];

    #   users.drfoobar = {
    #     programs.noctalia = {
    #       enable = true;

    #       # settings = { ... };
    #     };
    #   };
    # };
    imports = [
      inputs.noctalia.nixosModules.default
    ];
    # enable the systemd service
    programs.noctalia = {
      enable = true;

      # Enables NetworkManager, Bluetooth, UPower, and a power profile service.
      recommendedServices.enable = true;
      systemd.enable = true;
    };
  };
}
