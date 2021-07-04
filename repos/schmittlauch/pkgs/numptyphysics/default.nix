{ stdenv
, fetchFromGitHub
, lib
, SDL
, SDL_image
, SDL_ttf
, libGL
, glib
, pkgconfig
}:

stdenv.mkDerivation rec {
  name = "numptyphysics";
  version = "0.3.7";
  src = fetchFromGitHub {
    owner = "thp";
    repo = "numptyphysics";
    rev = version;
    sha256 = "1g3pl5ghan7g173zgwz0jkm3swy2r00gng392w25fsj5lf1g1v5x";
  };
  nativeBuildInputs = [ pkgconfig ];
  buildInputs = [ SDL SDL_image SDL_ttf glib libGL ];
  enableParallelBuilding = true;
  makeFlags = [ "PLATFORM=sdl1" "V=1" "DESTDIR=$(out)" "PREFIX=''" ];

  meta = {
    maintainers = [ lib.maintainers.schmittlauch ];
    license = lib.licenses.gpl3Plus;
    description = "a drawing puzzle game based on construction and physics puzzles";
    longDescription = ''
      Harness gravity with your crayon and set about creating blocks, ramps, levers, pulleys and whatever else you fancy to get the little red thing to the little yellow thing.

      Numpty Physics is a drawing puzzle game in the spirit (and style?) of Crayon Physics using the same excellent Box2D engine. Note though that I've not actually played CP so the experience may be very different. Numpty Physics includes a built-in editor so that you may build (and submit) your own levels.
      '';
  };
}
