{ lib, stdenv, fetchFromGitHub, autoreconfHook, yacc, ncurses, libressl, libevent }:

stdenv.mkDerivation rec {
  pname = "telescope";
  version = "0.3";

  src = fetchFromGitHub {
    owner = "omar-polo";
    repo = pname;
    rev = version;
    hash = "sha256-BssB2cZx4rEutgk+P0HCd6eQ8gzKDVIl2JA4B4kw5XI=";
  };

  nativeBuildInputs = [ autoreconfHook yacc ];

  buildInputs = [ ncurses libressl libevent ];

  meta = with lib; {
    description = "Telescope is a w3m-like browser for Gemini";
    homepage = "https://telescope.omarpolo.com/";
    license = licenses.isc;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
    broken = stdenv.isDarwin; # explicit_bzero() compatibility function symbol exported in libressl
  };
}
