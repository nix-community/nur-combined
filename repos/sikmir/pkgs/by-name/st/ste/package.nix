{
  lib,
  stdenv,
  fetchFromSourcehut,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ste";
  version = "0.7.7";

  src = fetchFromSourcehut {
    owner = "~strahinja";
    repo = "ste";
    rev = "v${finalAttrs.version}";
    hash = "sha256-BzbpwvXdzA+V3GDgfwXz8miaOoHSEY9hLfUaQG7+sNI=";
  };

  FALLBACKVER = finalAttrs.version;

  installFlags = [ "PREFIX=$(out)" ];

  meta = {
    description = "Simple table editor";
    homepage = "https://strahinja.srht.site/ste";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.linux;
    skip.ci = stdenv.isDarwin;
    mainProgram = "ste";
  };
})
