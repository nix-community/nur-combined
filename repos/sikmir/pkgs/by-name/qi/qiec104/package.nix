{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch,
  qt5,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "qiec104";
  version = "1.1";

  src = fetchFromGitHub {
    owner = "MicroKoder";
    repo = "QIEC104";
    tag = "v${finalAttrs.version}";
    hash = "sha256-0iHcn3AMrqi0t/6JXYQsVFQaevwNgk27e4BjJvY1GtA=";
  };

  patches = [
    # gcc support
    (fetchpatch {
      url = "https://github.com/MicroKoder/QIEC104/commit/804916a811e561e4a73b14d475a76c84bfb5b58d.patch";
      hash = "sha256-H1IJ8tBL5+4GO5WGMrDDwU65ylgA0QOhq9eZzRN6TxM=";
    })
  ];

  nativeBuildInputs = [
    qt5.qmake
    qt5.wrapQtAppsHook
  ];

  postInstall = ''
    install -Dm755 Q104 -t $out/bin
  '';

  meta = {
    description = "Small IEC104 client";
    homepage = "https://github.com/MicroKoder/QIEC104";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
  };
})
