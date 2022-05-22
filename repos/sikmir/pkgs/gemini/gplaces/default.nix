{ lib, stdenv, fetchFromGitHub, pkg-config, curl, openssl, memstreamHook }:

stdenv.mkDerivation rec {
  pname = "gplaces";
  version = "2022-04-14";

  src = fetchFromGitHub {
    owner = "dimkr";
    repo = pname;
    rev = "439f5e856c7aa6d1664e4d381623e5ec3d845980";
    hash = "sha256-1ckdpG1VwI7kmbc36NePDsBOPe6scNZY6QTHbgqQBFA=";
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
