{
  lib,
  stdenv,
  fetchFromSourcehut,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "table";
  version = "0.7.20";

  src = fetchFromSourcehut {
    owner = "~strahinja";
    repo = "table";
    tag = "v${finalAttrs.version}";
    hash = "sha256-vS1epeA/ZTIwpNaQrb6iX/5bdWPiGxcGLNf8PLctu34=";
  };

  FALLBACKVER = finalAttrs.version;

  installFlags = [ "PREFIX=$(out)" ];

  meta = {
    description = "Command line utility to format and display CSV";
    homepage = "https://strahinja.srht.site/table";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.linux;
    skip.ci = stdenv.isDarwin;
    mainProgram = "table";
  };
})
