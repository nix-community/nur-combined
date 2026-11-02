{
  nixpkgs ? <nixpkgs>,
}:
{
  default = import ./trev.nix { inherit nixpkgs; };
  images = import ./images.nix { };
  libs = import ./libs.nix { };
  packages = import ./packages.nix { };
  static-pie = import ./static-pie.nix { };
  trev = import ./trev.nix { inherit nixpkgs; };
}
