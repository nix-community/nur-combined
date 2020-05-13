{ pkgs ? import <nixpkgs> {} }:
{
  # depp = pkgs.callPackage ./depp {};
  daybook = pkgs.callPackage ./daybook {};
  /*
  slide = pkgs.callPackage (pkgs.fetchFromGitHub {
    owner = "kmein";
    repo = "slide";
    rev = "2a5129bbb6a4f24e02a9bc0c73cbd8b5e454c9be";
    sha256 = "1pydx4a00hssbgcyyasxrihhr344hcrs95xwlz0gj14w50d9wabm";
  }) {};
  */
  mahlzeit = pkgs.haskellPackages.callPackage ./mahlzeit {};
  python3Packages = {
    # sncli = pkgs.python3Packages.callPackage ./sncli {};
    # spotify-cli-linux = pkgs.python3Packages.callPackage ./spotify-cli-linux {};
    # instaloader = pkgs.python3Packages.callPackage ./instaloader {};
  };
  text2pdf = pkgs.callPackage ./text2pdf {};
}
