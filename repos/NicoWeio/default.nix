{ pkgs }:
let
  pythonPackages = pkgs.python314Packages;
  healpy = pythonPackages.callPackage ./jammy-flows/healpy.nix { };
  mhealpy = pythonPackages.callPackage ./jammy-flows/mhealpy.nix { inherit healpy; };
in
{
  crpropa = pkgs.callPackage ./crpropa {
    python = pkgs.python312;
    numpy = pkgs.python312Packages.numpy;
  };
  radiopropa = pkgs.callPackage ./radiopropa {
    python = pkgs.python312;
    numpy = pkgs.python312Packages.numpy;
  };
  rainlendar2 = pkgs.callPackage ./rainlendar2 { };
  jammy-flows = pythonPackages.callPackage ./jammy-flows { inherit mhealpy; };
}
