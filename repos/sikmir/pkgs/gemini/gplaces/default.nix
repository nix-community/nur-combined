{ lib, stdenv, fetchFromGitHub, pkg-config, curl, openssl, memstreamHook }:

stdenv.mkDerivation rec {
  pname = "gplaces";
  version = "0.16.27";

  src = fetchFromGitHub {
    owner = "dimkr";
    repo = "gplaces";
    rev = "v${version}";
    hash = "sha256-mC45OsDb1+qE8cYhuNsSwLEvOXjui33ENC3eYviyLyk=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ curl openssl ] ++ lib.optional stdenv.isDarwin memstreamHook;

  installFlags = [ "PREFIX=$(out)" ];

  meta = with lib; {
    description = "A simple terminal based Gemini client";
    inherit (src.meta) homepage;
    license = licenses.gpl3Plus;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
