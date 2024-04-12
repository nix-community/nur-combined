{ pkgs
, lib
, inputs
, hostname
, ...
}:

let
  inherit (inputs) self;

in
{
  imports = [
    "${self}/system/profiles/hyprland.nix"
    "${self}/system/profiles/graphics.nix"
    "${self}/system/profiles/vm.nix"
    "${self}/system/profiles/pci-passthrough.nix"
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
