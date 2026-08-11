/*
nix-build -E 'with import <nixpkgs> {}; callPackage ./default.nix {}'
*/

{ lib, stdenv, fetchFromGitHub, fltk }:

stdenv.mkDerivation rec {
  pname = "rasterview";
  version = "1.8";
  buildInputs = [ fltk ];
  src = fetchFromGitHub {
    repo = "rasterview";
    owner = "michaelrsweet";
    rev = "v${version}";
    sha256 = "M65kar3axl6QLeFKpUFsF7SO68oq/wcWZcd9uOCC+/U=";
  };
  meta = with lib; {
    description = "Viewer for CUPS/PWG/Apple raster files";
    homepage = "https://github.com/michaelrsweet/rasterview";
    license = licenses.asl20;
    platforms = platforms.linux;
    # TODO all platforms
  };
}
