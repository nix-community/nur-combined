{
  lib,
  stdenv,
  fetchFromSourcehut,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "sled";
  version = "0.20.3";

  src = fetchFromSourcehut {
    owner = "~strahinja";
    repo = "sled";
    rev = "v${finalAttrs.version}";
    hash = "sha256-JYTQ9ZI4bu8WjlueS2+E0IZn40mckIlvV7292bNv25M=";
  };

  postPatch = ''
    cp config.{Linux,mk}
  '';

  FALLBACKVER = finalAttrs.version;

  installFlags = [ "PREFIX=$(out)" ];

  meta = {
    description = "Simple text editor";
    homepage = "https://strahinja.srht.site/sled";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.linux;
    skip.ci = stdenv.isDarwin;
    mainProgram = "sled";
  };
})
