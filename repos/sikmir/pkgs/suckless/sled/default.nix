{ lib, stdenv, fetchFromSourcehut, redo-apenwarr }:

stdenv.mkDerivation (finalAttrs: {
  pname = "sled";
  version = "0.11.8";

  src = fetchFromSourcehut {
    owner = "~strahinja";
    repo = "sled";
    rev = "v${finalAttrs.version}";
    hash = "sha256-0Qf1Mxe9Q2KuFCs1bOwi8ALHKgFh3BojSoYOEhCquqw=";
  };

  nativeBuildInputs = [ redo-apenwarr ];

  buildPhase = ''
    runHook preBuild
    export FALLBACKVER=${finalAttrs.version}
    export FALLBACKDATE=1970-01-01
    redo all
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    PREFIX=$out redo install
    runHook postInstall
  '';

  meta = with lib; {
    description = "Simple text editor";
    homepage = "https://strahinja.srht.site/sled";
    license = licenses.gpl3Plus;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
})
