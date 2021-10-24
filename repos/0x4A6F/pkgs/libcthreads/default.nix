{ lib
, stdenv
, fetchFromGitHub
, autoreconfHook
, pkg-config
, libcerror
, libtool
}:

stdenv.mkDerivation rec {
  pname = "libcthreads";
  version = "20200508";

  src = fetchFromGitHub {
    owner = "libyal";
    repo = "libcthreads";
    rev = version;
    sha256 = "025hahz9animzssx0hxxc5rv98kh69q7sps6zlsdgw5c4w0nin0j";
  };

  patches = [ ./libcthreads.patch ];

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];
  buildInputs = [
    libcerror
    libtool
  ];

  meta = {
    homepage = "https://github.com/libyal/libcthreads";
    description = "Library for cross-platform C threads functions";
    license = lib.licenses.lgpl3Plus;
    platforms = lib.platforms.unix;
  };
}
