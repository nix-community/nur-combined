{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  curl,
  openssl,
  libidn2,
  file,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gplaces";
  version = "0.19.8";

  src = fetchFromGitHub {
    owner = "dimkr";
    repo = "gplaces";
    tag = "v${finalAttrs.version}";
    hash = "sha256-6BQimygOt+p1WZgpEXK2Icr/SxjF2tmjupJjDT8i5oo=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    curl
    openssl
    libidn2
    file # for libmagic
  ];

  makeFlags = [
    "CC:=$(CC)"
    "VERSION=${finalAttrs.version}"
  ];

  installFlags = [ "PREFIX=$(out)" ];

  meta = {
    description = "A simple terminal based Gemini client";
    homepage = "https://github.com/dimkr/gplaces";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
    broken = stdenv.isDarwin;
  };
})
