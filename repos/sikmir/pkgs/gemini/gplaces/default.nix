{ lib, stdenv, fetchFromGitHub, pkg-config, curl, openssl, memstreamHook }:

stdenv.mkDerivation (finalAttrs: {
  pname = "gplaces";
  version = "0.16.34";

  src = fetchFromGitHub {
    owner = "dimkr";
    repo = "gplaces";
    rev = "v${finalAttrs.version}";
    hash = "sha256-CpMEtgJJ95LiW6mCASRriy8cNF7bmKAouK0RTh4VcC8=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ curl openssl ] ++ lib.optional stdenv.isDarwin memstreamHook;

  makeFlags = [ "VERSION=${finalAttrs.version}" ];

  installFlags = [ "PREFIX=$(out)" ];

  meta = with lib; {
    description = "A simple terminal based Gemini client";
    inherit (finalAttrs.src.meta) homepage;
    license = licenses.gpl3Plus;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
    broken = stdenv.isDarwin;
  };
})
