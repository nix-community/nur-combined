{ lib, stdenv, fetchFromGitHub, autoreconfHook, yacc, ncurses, libressl, libevent }:

stdenv.mkDerivation rec {
  pname = "telescope";
  version = "0.4.1";

  src = fetchFromGitHub {
    owner = "omar-polo";
    repo = pname;
    rev = version;
    hash = "sha256-B7CpM7NQck731Q1iZ5/n1X8fquOaZex0MqZQwGp8ZY8=";
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
