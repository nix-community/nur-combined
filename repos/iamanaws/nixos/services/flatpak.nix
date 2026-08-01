{ inputs, ... }:

{
  imports = [ inputs.nix-flatpak.nixosModules.nix-flatpak ];

  # https://flatpak.org/setup/NixOS
  services.flatpak = {
    enable = true;
    uninstallUnmanaged = true;
    update.onActivation = true;
  };

  xdg.portal.enable = true;
}
