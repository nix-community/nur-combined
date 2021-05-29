# Hardware-related modules
{ ... }:

{
  imports = [
    ./bluetooth.nix
    ./ergodox.nix
    ./networking.nix
    ./sound.nix
    ./upower.nix
  ];
}
