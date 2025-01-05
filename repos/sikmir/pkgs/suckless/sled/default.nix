{
  lib,
  stdenv,
  fetchFromSourcehut,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "sled";
  version = "0.19.2";

  src = fetchFromSourcehut {
    owner = "~strahinja";
    repo = "sled";
    rev = "v${finalAttrs.version}";
    hash = "sha256-C/iRne2khZ31meZJ85AsEGMN7dTSOZ8CyIWQVBugT6Q=";
  };

  postPatch = ''
    substituteInPlace sled.c \
      --replace-fail "open(to, O_WRONLY | O_CREAT | O_TRUNC)" "open(to, O_WRONLY | O_CREAT | O_TRUNC, 0644)"
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
