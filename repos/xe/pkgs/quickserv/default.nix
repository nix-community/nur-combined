{ pkgs ? import <nixpkgs> { } }:
with pkgs;

buildGoPackage rec {
  name = "quickserv";
  version = "1.0.0";
  goPackagePath = "tulpa.dev/Xe/quickserv";
  src = fetchgit {
    url = "https://tulpa.dev/Xe/quickserv";
    rev = "933859e95e7c666e5247db58f2194ac65f3c3cad";
    sha256 = "1cya6rcism40q1vpdfzq3s5igfx5xc4dhf722dgr2k54y7kh9w0h";
  };
  goDeps = ./deps.nix;
  preBuild = ''
    export CGO_ENABLED=0
    buildFlagsArray+=(-pkgdir "$TMPDIR")
  '';

  allowGoReference = false;
}
