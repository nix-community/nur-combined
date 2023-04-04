{ lib, stdenv, fetchFromGitLab, cmake, SDL2, curl, ffmpeg, pugixml, pkgconf, freetype, freeimage, alsa-lib }:

stdenv.mkDerivation rec{
  pname = "emulationstation-de";
  version = "2.0.0";

  src = fetchFromGitLab {
    owner  = "es-de";
    repo   = "emulationstation-de";
    rev    = "v${version}";
    hash   = "sha256-HTWspnZCNTwbEF394FlsGlRML9zbVqd7jVf+ElpOkE0=";
  };

  patches = [ ./es_find_rules.patch ];

  nativeBuildInputs = [ cmake pkgconf ];

  buildInputs = [ SDL2 curl ffmpeg pugixml freetype freeimage alsa-lib ];

  meta = with lib; {
    description = "A frontend for browsing and launching games from your multi-platform game collection.";
    homepage    = "https://es-de.org/";
    license = licenses.mit;
    platforms   = lib.platforms.linux;
  };
}
