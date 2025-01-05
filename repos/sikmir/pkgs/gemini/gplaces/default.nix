{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  curl,
  openssl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gplaces";
  version = "0.19.7";

  src = fetchFromGitHub {
    owner = "dimkr";
    repo = "gplaces";
    tag = "v${finalAttrs.version}";
    hash = "sha256-u/JO2PNEZhmE068toBLHUJoWOkX4xoOKeIQN1hiCxlg=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    curl
    openssl
  ];

  makeFlags = [ "VERSION=${finalAttrs.version}" ];

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
