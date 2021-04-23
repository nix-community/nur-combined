# Common modules
{ ... }:

{
  imports = [
    ./documentation.nix
    ./ergodox.nix
    ./language.nix
    ./media.nix
    ./networking.nix
    ./nix.nix
    ./packages.nix
    ./users.nix
  ];
}
