{ lib, stdenv, fetchFromGitLab, cmake, SDL2, curl, ffmpeg, pugixml, pkgconf
, freetype, freeimage, alsa-lib, libgit2 }:

stdenv.mkDerivation rec {
  pname = "emulationstation-de";
  version = "2.0.1";

  src = fetchFromGitLab {
    owner = "es-de";
    repo = "emulationstation-de";
    rev = "v${version}";
    hash = "sha256-kYxJjizsEKiwUlstmzQQBsDncqz2hZvh3tTZvZSnjIQ=";
  };

  patches = [ ./es_find_rules.patch ];

  nativeBuildInputs = [ cmake pkgconf ];

  buildInputs =
    [ SDL2 curl ffmpeg pugixml freetype freeimage alsa-lib libgit2 ];

  meta = with lib; {
    description =
      "A frontend for browsing and launching games from your multi-platform game collection.";
    homepage = "https://es-de.org/";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
