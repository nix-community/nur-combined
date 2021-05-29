# Common modules
{ ... }:

{
  imports = [
    ./hardware
    ./home.nix
    ./profiles
    ./services
    ./system
  ];
}
