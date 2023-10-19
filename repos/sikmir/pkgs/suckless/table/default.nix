{ lib, stdenv, fetchFromSourcehut, redo-apenwarr }:

stdenv.mkDerivation (finalAttrs: {
  pname = "table";
  version = "0.6.22";

  src = fetchFromSourcehut {
    owner = "~strahinja";
    repo = "table";
    rev = "v${finalAttrs.version}";
    hash = "sha256-xN8U/5hgM/vmfxJ+jpTRyFY5TKxNDPtritVBaJr3L1I=";
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
    description = "Command line utility to format and display CSV";
    homepage = "https://strahinja.srht.site/table";
    license = licenses.gpl3Plus;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.linux;
    skip.ci = stdenv.isDarwin;
    mainProgram = "table";
  };
})
