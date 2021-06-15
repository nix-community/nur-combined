# System-related modules
{ ... }:

{
  imports = [
    ./boot.nix
    ./documentation.nix
    ./language.nix
    ./media.nix
    ./nix.nix
    ./packages.nix
    ./users.nix
  ];
}
