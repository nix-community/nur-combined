{ lib
, stdenv
, fetchFromGitHub
, autoreconfHook
}:

stdenv.mkDerivation rec {
  pname = "libcerror";
  version = "20201121";

  src = fetchFromGitHub {
    owner = "libyal";
    repo = "libcerror";
    rev = version;
    sha256 = "09z8m0p64bryvp70lyxnqqr4yj47mscibzqqzyzghmjxcmax41pr";
  };

  nativeBuildInputs = [
    autoreconfHook
  ];

  meta = {
    homepage = "https://github.com/libyal/libcerror";
    description = "Library for cross-platform C error functions";
    license = lib.licenses.lgpl3Plus;
    platforms = lib.platforms.unix;
  };
}
