{
  lib,
  stdenv,
  fetchFromGitHub,
  qt5,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "qiec104";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "MicroKoder";
    repo = "QIEC104";
    tag = "v${finalAttrs.version}";
    hash = "sha256-/kIAWxeJATKSEqXfRA3/6+TbHVeaIWZqsMYumvj2OuU=";
  };

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
