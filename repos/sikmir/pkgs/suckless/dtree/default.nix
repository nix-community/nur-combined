{ lib, stdenv, fetchFromSourcehut, redo-apenwarr }:

stdenv.mkDerivation (finalAttrs: {
  pname = "dtree";
  version = "0.1.3";

  src = fetchFromSourcehut {
    owner = "~strahinja";
    repo = "dtree";
    rev = "v${finalAttrs.version}";
    hash = "sha256-bvMJVPGYhNaWMAUyOlK4dci5/I/wYXIv2tXR+0Mz534=";
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
    description = "Command line program to draw trees";
    homepage = "https://strahinja.srht.site/dtree";
    license = licenses.gpl3Plus;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
})
