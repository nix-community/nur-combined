{ lib, stdenv, fetchFromSourcehut, redo-apenwarr }:

stdenv.mkDerivation (finalAttrs: {
  pname = "poe";
  version = "1.7.2";

  src = fetchFromSourcehut {
    owner = "~strahinja";
    repo = "poe";
    rev = "v${finalAttrs.version}";
    hash = "sha256-mtHSB2s3fSchLrYnAOJjvwepzlNWyWb4nvCRe3C7zeI=";
  };

  nativeBuildInputs = [ redo-apenwarr ];

  buildPhase = ''
    runHook preBuild
    export FALLBACKVER=${finalAttrs.version}
    export FALLBACKDATE=1970-01-01
    POE_CC=$CC redo all
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    PREFIX=$out redo install
    runHook postInstall
  '';

  meta = with lib; {
    description = ".po file editor";
    homepage = "https://strahinja.srht.site/poe";
    license = licenses.gpl3Plus;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.linux;
    skip.ci = stdenv.isDarwin;
    mainProgram = "poe";
  };
})
