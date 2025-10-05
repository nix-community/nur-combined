{
  lib,
  stdenv,
  fetchFromGitHub,
  openssl,
}:

stdenv.mkDerivation {
  pname = "btpd";
  version = "2020-04-07";

  src = fetchFromGitHub {
    owner = "btpd";
    repo = "btpd";
    rev = "a3a10dfe1ece4a726530353a7b208c0cb4ff7e0d";
    hash = "sha256-9LvhJhdlGC0awtF3SFlv2oHMCH0BrG49Op2EeaPJsDE=";
  };

  buildInputs = [ openssl ];

  makeFlags = [ "CC:=$(CC)" ];

  installFlags = [ "PREFIX=$(out)" ];

  meta = {
    description = "The BitTorrent Protocol Daemon";
    homepage = "https://github.com/btpd/btpd";
    license = lib.licenses.bsd2;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
  };
}
