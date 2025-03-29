{ pkgs, ... }:
{
  services.gnome.gnome-keyring.enable = true;
  environment.systemPackages = with pkgs; [
    seahorse
  ];
}
