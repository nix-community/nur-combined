# What's needed to enable flatpak
{ ... }:

{
  services.flatpak.enable = true;
  xdg.portal.enable = true;
}
