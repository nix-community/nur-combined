{ lib, stdenv, fetchFromGitHub, boost, libmpdclient, ncurses, pkg-config
, readline, libiconv, icu, curl, autoreconfHook
, outputsSupport ? true # outputs screen
, visualizerSupport ? false, fftw ? null # visualizer screen
, clockSupport ? true # clock screen
, taglibSupport ? true, taglib ? null # tag editor
}:

assert visualizerSupport -> (fftw != null);
assert taglibSupport -> (taglib != null);

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
    ++ lib.optional outputsSupport "--enable-outputs"
    ++ lib.optional visualizerSupport "--enable-visualizer --with-fftw"
    ++ lib.optional clockSupport "--enable-clock"
    ++ lib.optional taglibSupport "--with-taglib";

  nativeBuildInputs = [ autoreconfHook pkg-config ];

  buildInputs = [ boost libmpdclient ncurses readline libiconv icu curl ]
    ++ lib.optional visualizerSupport fftw
    ++ lib.optional taglibSupport taglib;

  meta = {
    description = "A featureful ncurses based MPD client inspired by ncmpc";
    homepage    = "https://ncmpcpp.rybczak.net/";
    license     = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ jfrankenau koral lovek323 ];
    platforms   = lib.platforms.all;
  };
}
