# To make `nix run nixpkgs#hello` and such use the same nixpkgs used to build this, so that it doesn't take forever
{ inputs, ... }:
{
  nix.registry.nixpkgs.to = {
    type = "path";
    path = inputs.nixpkgs.outPath;
  };
  nix.nixPath = [ "nixpkgs=flake:nixpkgs" ];
}
