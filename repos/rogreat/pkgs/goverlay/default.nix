{
  autoPatchelfHook,
  fetchFromGitHub,
  fpc,
  lazarus-qt6,
  lib,
  nix-update-script,
  qt6Packages,
  stdenv,
  vulkan-tools,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "goverlay";
  version = "1.4.0";

  src = fetchFromGitHub {
    owner = "benjamimgois";
    repo = "goverlay";
    rev = finalAttrs.version;
    sha256 = "sha256-Y9ZrsyzkQX0bGvyYHvyU6hAadIkEr9Nv182aJL6Gm/o=";
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

  preFixup = ''
    qtWrapperArgs+=(
      --suffix PATH : ${
        lib.makeBinPath [
          vulkan-tools
        ]
      })
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
