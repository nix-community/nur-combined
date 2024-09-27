# Configuration that spans across system and home, or are almagations of modules
{ ... }:
{
  imports = [
    ./bluetooth
    ./devices
    ./gtk
    ./laptop
    ./wm
    ./x
  ];
}
