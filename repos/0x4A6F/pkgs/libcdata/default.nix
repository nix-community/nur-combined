{ lib
, stdenv
, fetchFromGitHub
, autoreconfHook
, pkg-config
, libcerror
, libcthreads
}:

stdenv.mkDerivation rec {
  pname = "libcdata";
  version = "20200509";

  src = fetchFromGitHub {
    owner = "libyal";
    repo = "libcdata";
    rev = version;
    sha256 = "1rm0dsch9g353mmhqpqbjyz9407vzm10mhb5qdzp7jyk3j2vyhrj";
  };

  patches = [ ./libcdata.patch ];

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];
  buildInputs = [
    libcerror
    libcthreads
  ];

  meta = {
    homepage = "https://github.com/libyal/libcdata";
    description = "Library for cross-platform C generic data functions";
    license = lib.licenses.lgpl3Plus;
    platforms = lib.platforms.unix;
  };
}
