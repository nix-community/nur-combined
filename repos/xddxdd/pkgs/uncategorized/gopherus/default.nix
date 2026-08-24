{
  fetchurl,
  stdenv,
  lib,
  ncurses,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "gopherus";
  version = "1.2.2";
  src = fetchurl {
    url = "https://gopherus.sourceforge.net/gopherus-1.2.2.tar.xz";
    hash = "sha256-7l/7ZK5KQ/V2Ym02Sbc0qAGov36P4P0hVWzIzbQzipo=";
  };
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
    description = "Free, multiplatform, console-mode gopher client that provides a classic text interface to the gopherspace";
    homepage = "http://gopherus.sourceforge.net/";
    license = with lib.licenses; [ bsd2 ];
    mainProgram = "gopherus";
  };
})
