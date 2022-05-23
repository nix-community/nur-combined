# System-related modules
{ ... }:

{
  imports = [
    ./boot
    ./documentation
    ./language
    ./nix
    ./packages
    ./podman
    ./users
  ];
}
