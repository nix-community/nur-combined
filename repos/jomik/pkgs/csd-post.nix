{ stdenv, pkgs, lib, ... }:

with lib;
let
  version = "20181217";
  rev = "959ef959b6064c26e76db958d0d6be098787cbd1";
  sha256 = "1r4ghyi09rymkrxym89dwarjbn0p5h43x8pwyi7vx49xha05w3qq";
in stdenv.mkDerivation rec {
  inherit version;
  name = "csd-post-${version}";
  src = pkgs.fetchurl {
    inherit sha256;
    url = "https://gitlab.com/openconnect/openconnect/raw/${rev}/trojans/csd-post.sh";
  };
  buildInputs = with pkgs; [ xmlstarlet curl ];
  unpackPhase = ":";
  installPhase = ''
    install -m 755 -DT $src $out/bin/csd-post
  '';
}
