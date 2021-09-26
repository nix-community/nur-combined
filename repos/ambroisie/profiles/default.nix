# Configuration that spans accross system and home, or are almagations of modules
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
