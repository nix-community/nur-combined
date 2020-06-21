{ pkgs ? import <nixpkgs> {} }:
{
  depp = pkgs.callPackage ./depp {};
  devour = pkgs.callPackage ./devour {};
  daybook = pkgs.callPackage ./daybook {};
  slide = pkgs.callPackage ./slide {};
  mahlzeit = pkgs.haskellPackages.callPackage ./mahlzeit {};
  python3Packages = pkgs.recurseIntoAttrs rec {
    # sncli = pkgs.python3Packages.callPackage ./sncli {};
    spotify-cli-linux = pkgs.python3Packages.callPackage ./spotify-cli-linux {};
    instaloader = pkgs.python3Packages.callPackage ./instaloader {};
    pygtrie = pkgs.python3Packages.callPackage ./pygtrie {};
    betacode = pkgs.python3Packages.callPackage ./betacode { inherit pygtrie; };
  };
  text2pdf = pkgs.callPackage ./text2pdf {};
  vimv = pkgs.callPackage ./vimv {};
  # when = pkgs.callPackage ./when {};
}
