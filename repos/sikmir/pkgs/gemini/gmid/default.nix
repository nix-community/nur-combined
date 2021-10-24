{ lib, stdenv, fetchFromGitHub, bison, libressl, libevent }:

stdenv.mkDerivation rec {
  pname = "gmid";
  version = "1.7.5";

  src = fetchFromGitHub {
    owner = "omar-polo";
    repo = pname;
    rev = version;
    hash = "sha256-BBd0AL5jRRslxzDnxcTZRR+8J5D23NAQ7mp9K+leXAQ=";
  };

  nativeBuildInputs = [ bison ];

  buildInputs = [ libressl libevent ];

  configurePhase = ''
    ./configure PREFIX=$out
  '';

  meta = with lib; {
    description = "Simple and secure Gemini server";
    homepage = "https://gmid.omarpolo.com/";
    license = licenses.isc;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
    broken = stdenv.isDarwin; # explicit_bzero() compatibility function symbol exported in libressl
  };
}
