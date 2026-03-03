{
  lib,
  stdenv,
  fetchFromSourcehut,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "poe";
  version = "2.0";

  src = fetchFromSourcehut {
    owner = "~strahinja";
    repo = "poe";
    rev = "v${finalAttrs.version}";
    hash = "sha256-7+cXRDBIZha6mCi+z2j58cRxP3zSzrG80ABOcqRg3jA=";
  };

  postPatch = ''
    cp config.{Linux,mk}
  '';

  FALLBACKVER = finalAttrs.version;

  installFlags = [ "PREFIX=$(out)" ];

  meta = {
    description = ".po file editor";
    homepage = "https://strahinja.srht.site/poe";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.linux;
    skip.ci = stdenv.isDarwin;
    mainProgram = "poe";
  };
})
