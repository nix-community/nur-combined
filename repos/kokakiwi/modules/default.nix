{ pkgs, lib }:
{
  home-manager = import ./home-manager {
    inherit pkgs lib;
  };
  nixos = import ./nixos {
    inherit pkgs lib;
  };
}
