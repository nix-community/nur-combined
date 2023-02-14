{ lib, stdenv, fetchFromGitHub, pkg-config, curl, openssl, memstreamHook }:

stdenv.mkDerivation (finalAttrs: {
  pname = "gplaces";
  version = "0.16.35";

  src = fetchFromGitHub {
    owner = "dimkr";
    repo = "gplaces";
    rev = "v${finalAttrs.version}";
    hash = "sha256-ZxBIwKP6PZxZapvdZYfOLZsxUhr2WJlI8oYyO/KHYgc=";
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
