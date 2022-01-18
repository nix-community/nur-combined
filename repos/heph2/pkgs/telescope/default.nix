{ stdenv
, lib
, fetchFromGitHub
, pkg-config
, bison
, libevent
, libressl
, ncurses
, autoreconfHook
, buildPackages
}:

stdenv.mkDerivation rec {
  pname = "telescope";
  version = "0.7.1";

  src = fetchFromGitHub {
    owner = "omar-polo";
    repo = pname;
    rev = "bf5b33f40e876afe41fd486ff5d3eb182dfaf046";
    sha256 = "lJlJ5ushTzF7j+BKQxVhV8zyB8XhSFOOzBS0FjwFWZk=";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    bison
  ];

  buildInputs = [
    libevent
    libressl
    ncurses
  ];

  configureFlags = [
    "HOSTCC=${buildPackages.stdenv.cc}/bin/${buildPackages.stdenv.cc.targetPrefix}cc"
  ];

  meta = with lib; {
    description = "Telescope is a w3m-like browser for Gemini";
    homepage = "https://telescope.omarpolo.com/";
    license = licenses.isc;
    maintainers = with maintainers; [ heph2 ];
    platforms = platforms.unix;
  };
}
