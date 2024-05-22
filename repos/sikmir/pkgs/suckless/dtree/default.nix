{
  lib,
  stdenv,
  fetchFromSourcehut,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "dtree";
  version = "0.2.4";

  src = fetchFromSourcehut {
    owner = "~strahinja";
    repo = "dtree";
    rev = "v${finalAttrs.version}";
    hash = "sha256-yBu9nckWOt/EMPJbjyzWslGX7KivdR9fr+5laOpRmHM=";
  };

  FALLBACKVER = finalAttrs.version;

  installFlags = [ "PREFIX=$(out)" ];

  meta = with lib; {
    description = "Command line program to draw trees";
    homepage = "https://strahinja.srht.site/dtree";
    license = licenses.gpl3Plus;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
})
