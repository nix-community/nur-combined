{
  pkgs,
  lib,
  inputs,
  hostname,
  ...
}:

{
  imports = map (x: "${inputs.self}/system/profiles/" + x + ".nix") [
    "hyprland"
    "pci-passthrough"
    "vm"
  ];

  environment.systemPackages = with pkgs; [
    vim
    kitty
  ];
  networking.hostName = hostname;
  # Extra settings (22.11)
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  system.stateVersion = "23.11";
}
