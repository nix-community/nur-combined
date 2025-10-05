{
  lib,
  stdenv,
  fetchFromSourcehut,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "table";
  version = "0.7.18";

  src = fetchFromSourcehut {
    owner = "~strahinja";
    repo = "table";
    rev = "v${finalAttrs.version}";
    hash = "sha256-K1GDv7gqsW5coCrAuYf5SoLXdMT+3mkDpAO+WMczgic=";
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
