{
  lib,
  stdenv,
  fetchFromSourcehut,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "poe";
  version = "1.8.2";

  src = fetchFromSourcehut {
    owner = "~strahinja";
    repo = "poe";
    rev = "v${finalAttrs.version}";
    hash = "sha256-fQSn/nm9N8RFz/MPKtEU/aCHTGy3J9W0oSGH+siVDmg=";
  };

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
