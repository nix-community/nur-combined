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
    rev = "8d39ecac31b149e6d285c931679c7463daebf273";
    sha256 = "QGMtR35/k3mux99v+H6j3Ys4cdLnYEHtW0Tl/OaBcIY=";
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
