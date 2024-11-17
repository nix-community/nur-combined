{ ... }:
{
  imports = [
    ./build-machine.nix
    ./client
    ./handheld.nix
    ./pc.nix
  ];
}
