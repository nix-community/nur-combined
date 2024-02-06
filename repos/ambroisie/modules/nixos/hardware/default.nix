# Hardware-related modules
{ ... }:

{
  imports = [
    ./bluetooth
    ./ergodox
    ./firmware
    ./graphics
    ./networking
    ./sound
    ./trackball
    ./upower
  ];
}
