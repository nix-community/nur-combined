{ lib, stdenv, fetchFromGitHub, pkg-config, curl, openssl, memstreamHook }:

stdenv.mkDerivation rec {
  pname = "gplaces";
  version = "0.16.30";

  src = fetchFromGitHub {
    owner = "dimkr";
    repo = "gplaces";
    rev = "v${version}";
    hash = "sha256-W/tXwxJ4j7q3ka36TI7y/Psf9VHGXL/F2rNRGGkBKo0=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ curl openssl ] ++ lib.optional stdenv.isDarwin memstreamHook;

  makeFlags = [ "VERSION=${version}" ];

  installFlags = [ "PREFIX=$(out)" ];

  meta = with lib; {
    description = "A simple terminal based Gemini client";
    inherit (src.meta) homepage;
    license = licenses.gpl3Plus;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
    broken = stdenv.isDarwin;
  };
}
