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

stdenv.mkDerivation rec {
  pname = "goverlay";
  version = "dcc5684fed5010ae08d3f696b7e882352e61fae9";

  src = fetchFromGitHub {
    owner = "benjamimgois";
    repo = "goverlay";
    rev = version;
    sha256 = "sha256-jFEW9l/ggCUysR3H4ZVu5MLiqGY8ZCzHJjoc5jQS14k=";
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

  meta = with lib; {
    description = "Opensource project that aims to create a Graphical UI to help manage Linux overlays";
    homepage = "https://github.com/benjamimgois/goverlay";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ RoGreat ];
    platforms = platforms.linux;
    mainProgram = "goverlay";
  };
}
