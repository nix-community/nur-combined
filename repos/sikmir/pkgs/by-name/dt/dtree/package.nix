{
  lib,
  stdenv,
  fetchFromSourcehut,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "dtree";
  version = "0.2.12";

  src = fetchFromSourcehut {
    owner = "~strahinja";
    repo = "dtree";
    tag = "v${finalAttrs.version}";
    hash = "sha256-/n7Thtw8idA/MPz55CfQ6Ve/kmEoqlZuyBXdEMWkQhM=";
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
