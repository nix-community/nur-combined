{
  autoPatchelfHook,
  fetchFromGitHub,
  fpc,
  lazarus-qt6,
  lib,
  nix-update-script,
  qt6Packages,
  stdenv,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "goverlay";
  version = "d07ddfc3ff96bf6c3c29d4d69fafd081b2977813";

  src = fetchFromGitHub {
    owner = "benjamimgois";
    repo = "goverlay";
    rev = finalAttrs.version;
    sha256 = "sha256-LLFlVgCPlVLYU0Kjhg/5RKf7I2fpaTJ5s/tYddM04Ps=";
  };

  outputs = [
    "out"
    "man"
  ];

  nativeBuildInputs = [
    autoPatchelfHook
    fpc
    lazarus-qt6
    qt6Packages.wrapQtAppsHook
  ];

  buildInputs = [
    qt6Packages.libqtpas
    qt6Packages.qtbase
  ];

  installPhase = ''
    runHook preInstall
    make prefix=$out install
    runHook postInstall
  '';

  buildPhase = ''
    runHook preBuild
    HOME=$(mktemp -d) lazbuild --lazarusdir=${lazarus-qt6}/share/lazarus -B goverlay.lpi
    runHook postBuild
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Opensource project that aims to create a Graphical UI to help manage Linux overlays";
    homepage = "https://github.com/benjamimgois/goverlay";
    changelog = "https://github.com/benjamimgois/goverlay/releases/tag/nightly";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ RoGreat ];
    mainProgram = "goverlay";
    platforms = lib.platforms.linux;
  };
})
