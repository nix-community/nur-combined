# Hardware-related modules
{ ... }:

{
  imports = [
    ./bluetooth.nix
    ./ergodox.nix
    ./mx-ergo.nix
    ./networking.nix
    ./sound.nix
    ./upower.nix
  ];
}
