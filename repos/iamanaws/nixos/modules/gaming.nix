{ pkgs, ... }:

{
  hardware.graphics.enable32Bit = true;

  programs = {
    gamemode.enable = true;

    steam = {
      enable = true;
      extest.enable = true;
      protontricks.enable = true;

      # Open ports in the firewall for Steam Remote Play
      remotePlay.openFirewall = true;
      # Open ports for Steam local network game transfers
      localNetworkGameTransfers.openFirewall = true;

      extraCompatPackages = with pkgs; [
        proton-ge-bin
      ];

      # extraPackages = with pkgs; [
      #   hidapi
      # ];
    };
  };

  environment.systemPackages = with pkgs; [
    mangohud
    protonup-qt
    steam-run
    vulkan-tools
  ];
}
