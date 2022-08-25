# Build command: nix-build -E 'with import <nixpkgs> {}; pkgs.callPackage ./default.nix {}'
{ lib, stdenv, fetchFromGitLab, cmake, SDL2, curl, ffmpeg,
pugixml, pkgconf, freetype, freeimage, alsa-lib }:

let
  version = "1.2.6";

in stdenv.mkDerivation {
  pname = "emulationstation-de";
  inherit version;

  src = fetchFromGitLab {
    owner  = "es-de";
    repo   = "emulationstation-de";
    rev    = "v${version}";
    sha256 = "BiQnHtcKheEhwp0KKy9BCDIuZuAjmS8tWNyNw4nl5Fk=";
  };

  patches = [ ./es_find_rules.patch ];

  buildInputs = [ SDL2 curl cmake ffmpeg pugixml pkgconf freetype freeimage alsa-lib ];

#   # https://gitlab.com/es-de/emulationstation-de/-/blob/master/INSTALL.md#building-on-unix
#   configurePhase = ''
#     cmake .
#   '';
#
#   buildPhase = ''
#     make -j$NIX_BUILD_CORES
#   '';
#
#   installPhase = ''
#     mkdir -p $out/bin
#     mv * $out/bin
#   '';

  meta = with lib; {
    description = "EmulationStation Desktop Edition (ES-DE) is a frontend for browsing and launching games from your multi-platform game collection.";
    homepage    = "https://es-de.org/";
    license = licenses.mit;
    platforms   = lib.platforms.linux;
  };
}
