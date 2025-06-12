{
  stdenv,
  sources,
  lib,
  ncurses,
}:
stdenv.mkDerivation (finalAttrs: {
  inherit (sources.gopherus) pname version src;

  buildInputs = [ ncurses ];

  buildPhase = ''
    runHook preBuild

    make -f Makefile.lin gopherus

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 gopherus $out/bin/gopherus

    runHook postInstall
  '';

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Gopherus is a free, multiplatform, console-mode gopher client that provides a classic text interface to the gopherspace";
    homepage = "http://gopherus.sourceforge.net/";
    license = with lib.licenses; [ bsd2 ];
    mainProgram = "gopherus";
  };
})
