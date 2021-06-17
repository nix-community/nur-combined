{ stdenv
, fetchFromGitHub
, lib
, SDL2
, SDL2_image
, SDL2_ttf
, libGL
, glib
, pkgconfig
}:

stdenv.mkDerivation rec {
  name = "numptyphysics";
  version = "0.3.6";
  src = fetchFromGitHub {
    owner = "thp";
    repo = "numptyphysics";
    rev = version;
    sha256 = "03cqzp8wj00kwc5ykhk27vv9jpgcn8b99lkfzj557lmvvyx1rrsd";
  };
  nativeBuildInputs = [ pkgconfig ];
  buildInputs = [ SDL2 SDL2_image SDL2_ttf glib libGL ];
  enableParallelBuilding = true;
  patches = [
    # always build against libGL, as upstream check depends on FHS lib locations
    ./use-libgl.patch
  ];
  installFlags = [ "DESTDIR=$(out)" "PREFIX=''" ];

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
