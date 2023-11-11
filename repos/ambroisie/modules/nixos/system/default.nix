# System-related modules
{ ... }:

{
  imports = [
    ./boot
    ./docker
    ./documentation
    ./language
    ./nix
    ./packages
    ./podman
    ./printing
    ./users
  ];
}
