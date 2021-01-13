{ stdenv, lib, fetchFromGitHub
, autoPatchelfHook, pkgconfig, cmake
, audiofile, gtk2, libpng, gnome2
, libinstpatch, libsndfile
, fluidsynth
}:

stdenv.mkDerivation rec {
  pname = "swami";
  version = "2.2.1";

  src = fetchFromGitHub {
    owner = "swami";
    repo = "swami";
    rev = "v${version}";
    sha256 = "sha256-x+FsMVmkB3Y5SEYbSafz/opDBUKZf9JQRCX8NIwRyko=";
  };

  nativeBuildInputs = [ autoPatchelfHook pkgconfig cmake ];

  buildInputs = [
    audiofile gtk2 libpng gnome2.libgnomecanvas
    libinstpatch libsndfile
    fluidsynth
  ];

  meta = with lib; {
    description = "Instrument editor application.";
    homepage    = "http://www.swamiproject.org/";
    license     = licenses.gpl2;
    platforms   = platforms.unix;
  };
}
