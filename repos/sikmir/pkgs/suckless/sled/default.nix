{
  lib,
  stdenv,
  fetchFromSourcehut,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "sled";
  version = "0.13.2";

  src = fetchFromSourcehut {
    owner = "~strahinja";
    repo = "sled";
    rev = "v${finalAttrs.version}";
    hash = "sha256-7x3siICVeB/ZKeopOWtcdBEwvWYcTm4bcnuPsIsWm5Y=";
  };

  FALLBACKVER = finalAttrs.version;

  installFlags = [ "PREFIX=$(out)" ];

  meta = with lib; {
    description = "Simple text editor";
    homepage = "https://strahinja.srht.site/sled";
    license = licenses.gpl3Plus;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.linux;
    skip.ci = stdenv.isDarwin;
    mainProgram = "sled";
    broken = true;
  };
})
