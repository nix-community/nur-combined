{
  lib,
  stdenv,
  fetchFromSourcehut,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "dtree";
  version = "0.2.11";

  src = fetchFromSourcehut {
    owner = "~strahinja";
    repo = "dtree";
    rev = "v${finalAttrs.version}";
    hash = "sha256-MGBJshNiQgwr/0HMm4dm0eUqLHxyYIjBEA5ZdlVmoME=";
  };

  FALLBACKVER = finalAttrs.version;

  installFlags = [ "PREFIX=$(out)" ];

  meta = {
    description = "Command line program to draw trees";
    homepage = "https://strahinja.srht.site/dtree";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
})
