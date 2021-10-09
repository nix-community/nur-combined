{ lib, stdenv, fetchFromGitHub, which, yacc, libressl, libevent }:

stdenv.mkDerivation rec {
  pname = "gmid";
  version = "1.7.4";

  src = fetchFromGitHub {
    owner = "omar-polo";
    repo = pname;
    rev = version;
    hash = "sha256-yjbuLlcacV/NQE4UgywczXDkkqHMoIsHhdHAus0zw/0=";
  };

  nativeBuildInputs = [ which yacc ];

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
