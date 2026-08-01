{
  pkgs,
  nixosModules,
  ...
}:

{
  # Reuse the shared display stack (pipewire, portals, fonts, etc.)
  imports = [ nixosModules.display.default ];

  # pwnbox-specific GUI tools on top of the shared display module
  environment.systemPackages = with pkgs; [
    networkmanagerapplet
    vscode
  ];
}
