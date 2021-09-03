{ lib, stdenv, fetchFromGitHub, autoreconfHook, pkg-config, yacc, ncurses, libressl, libevent }:

stdenv.mkDerivation rec {
  pname = "telescope";
  version = "0.5.1";

  src = fetchFromGitHub {
    owner = "omar-polo";
    repo = pname;
    rev = version;
    hash = "sha256-CApZn0AxpjgzC4XTkjF3YBOX5ifYH4PDtqk+sU5OoDU=";
  };

  nativeBuildInputs = [ autoreconfHook pkg-config yacc ];

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
