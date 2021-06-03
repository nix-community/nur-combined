# Configuration that spans accross system and home, or are almagations of modules
{ ... }:
{
  imports = [
    ./bluetooth.nix
    ./devices.nix
    ./gtk.nix
    ./laptop.nix
    ./wm.nix
    ./x.nix
  ];
}
