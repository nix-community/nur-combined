# System-related modules
{ ... }:

{
  imports = [
    ./documentation.nix
    ./language.nix
    ./media.nix
    ./nix.nix
    ./packages.nix
    ./users.nix
  ];
}
