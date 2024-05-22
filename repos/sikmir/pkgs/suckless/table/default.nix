{
  lib,
  stdenv,
  fetchFromSourcehut,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "table";
  version = "0.7.8";

  src = fetchFromSourcehut {
    owner = "~strahinja";
    repo = "table";
    rev = "v${finalAttrs.version}";
    hash = "sha256-uXGeHowit5Yfweq+/64gP3O9QrITLn7in3R85UPdb1Y=";
  };

  FALLBACKVER = finalAttrs.version;

  installFlags = [ "PREFIX=$(out)" ];

  meta = with lib; {
    description = "Command line utility to format and display CSV";
    homepage = "https://strahinja.srht.site/table";
    license = licenses.gpl3Plus;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.linux;
    skip.ci = stdenv.isDarwin;
    mainProgram = "table";
  };
})
