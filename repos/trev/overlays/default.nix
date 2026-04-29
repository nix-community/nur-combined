{
  nixpkgs ? <nixpkgs>,
}:
{
  default = import ./trev.nix { inherit nixpkgs; };
  images = import ./images.nix { };
  libs = import ./libs.nix { inherit nixpkgs; };
  packages = import ./packages.nix { };
  python = import ./python.nix { };
  trev = import ./trev.nix { inherit nixpkgs; };
}
