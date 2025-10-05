{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  gtk-doc,
  pkg-config,
  cairo,
  expat,
  glib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "memphis";
  version = "0.2.3";

  src = fetchFromGitHub {
    owner = "jiuka";
    repo = "memphis";
    tag = finalAttrs.version;
    hash = "sha256-mBRu2EHEuoHz3scoVaYqAMBZXbG7XkKwdHe9O0gaDBk=";
  };

  nativeBuildInputs = [
    autoreconfHook
    gtk-doc
    pkg-config
  ];

  buildInputs = [
    cairo
    expat
    glib
  ];

  meta = {
    description = "Map-rendering for OpenStreetMap";
    homepage = "https://github.com/jiuka/memphis";
    license = lib.licenses.lgpl2Plus;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
})
