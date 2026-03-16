{
  nixpkgs ? <nixpkgs>,
}:
{
  default = import ./trev.nix { inherit nixpkgs; };
  trev = import ./trev.nix { inherit nixpkgs; };
  packages = import ./packages.nix { };
  libs = import ./libs.nix { inherit nixpkgs; };
  python = import ./python.nix { };
  images = import ./images.nix { };
}
