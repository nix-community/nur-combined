{ lib, stdenv, fetchFromSourcehut, redo-apenwarr }:

stdenv.mkDerivation (finalAttrs: {
  pname = "ste";
  version = "0.3.3";

  src = fetchFromSourcehut {
    owner = "~strahinja";
    repo = "ste";
    rev = "v${finalAttrs.version}";
    hash = "sha256-82XTVe3ayPKm0sZ/PSMNkBdoYBSLygWB/JBClXWq4r8=";
  };

  nativeBuildInputs = [ redo-apenwarr ];

  buildPhase = ''
    runHook preBuild
    export FALLBACKVER=${finalAttrs.version}
    redo all
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    PREFIX=$out redo install
    runHook postInstall
  '';

  meta = with lib; {
    description = "Simple table editor";
    homepage = "https://strahinja.srht.site/ste";
    license = licenses.gpl3Plus;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
})
