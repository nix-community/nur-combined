{ inputs, ... }:

{
  imports = [ inputs.nix-flatpak.homeManagerModules.nix-flatpak ];

  # https://flatpak.org/setup/NixOS
  services.flatpak = {
    enable = true;
    uninstallUnmanaged = true;
    update.onActivation = true;
  };
}
