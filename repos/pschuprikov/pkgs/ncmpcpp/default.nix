{ stdenv, fetchFromGitHub, boost, mpd_clientlib, ncurses, pkgconfig, readline
, libiconv, icu, curl, autoreconfHook
, outputsSupport ? true # outputs screen
, visualizerSupport ? false, fftw ? null # visualizer screen
, clockSupport ? true # clock screen
, taglibSupport ? true, taglib ? null # tag editor
}:

assert visualizerSupport -> (fftw != null);
assert taglibSupport -> (taglib != null);

with stdenv.lib;
stdenv.mkDerivation rec {
  pname = "ncmpcpp";
  version = "HEAD";

  src = fetchFromGitHub {
    owner = "ncmpcpp";
    repo = "ncmpcpp";
    rev = "7ee6de39a1540f87854335d5b226018276ce9ef9";
    sha256 = "sha256-pWRnJj9fQ+FAEUyA98ezn4rKAniDjRjpLyKzvAkO5JU";
  };

  configureFlags = [ "BOOST_LIB_SUFFIX=" ]
    ++ optional outputsSupport "--enable-outputs"
    ++ optional visualizerSupport "--enable-visualizer --with-fftw"
    ++ optional clockSupport "--enable-clock"
    ++ optional taglibSupport "--with-taglib";

  nativeBuildInputs = [ autoreconfHook pkgconfig ];

  buildInputs = [ boost mpd_clientlib ncurses readline libiconv icu curl ]
    ++ optional visualizerSupport fftw
    ++ optional taglibSupport taglib;

  meta = {
    description = "A featureful ncurses based MPD client inspired by ncmpc";
    homepage    = "https://ncmpcpp.rybczak.net/";
    license     = licenses.gpl2Plus;
    maintainers = with maintainers; [ jfrankenau koral lovek323 ];
    platforms   = platforms.all;
  };
}
