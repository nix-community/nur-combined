{
  stdenv,
  fetchFromGitHub,
  lib,
  copyDesktopItems,
  installShellFiles,
  makeDesktopItem,
  makeWrapper,

  cmake,
  curl,
  httplib,
  nlohmann_json,
  openssl,
  # https://gist.github.com/CMCDragonkai/1ae4f4b5edeb021ca7bb1d271caca999
  # https://github.com/BeamMP/BeamMP-Launcher/issues/186
  cacert_3108,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "beammp-launcher";
  version = "2.7.0";

  src = fetchFromGitHub {
    owner = "BeamMP";
    repo = "BeamMP-Launcher";
    tag = "v${finalAttrs.version}";
    hash = "sha256-+qdDGOLds2j00BRijFAZ8DMrnjvigs+z+w9+wbitJno=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    copyDesktopItems
    installShellFiles
    makeWrapper

    cmake
  ];

  buildInputs = [
    curl
    httplib
    nlohmann_json
    openssl
  ];

  desktopItems = [
    (makeDesktopItem {
      categories = [ "Game" ];
      comment = "Launcher for the BeamMP mod for BeamNG.drive";
      desktopName = "BeamMP-Launcher";
      exec = "BeamMP-Launcher";
      name = "BeamMP-Launcher";
      terminal = true;
    })
  ];

  installPhase = ''
    runHook preInstall
    installBin "BeamMP-Launcher"
    copyDesktopItems
    runHook postInstall
  '';

  postFixup = ''
    wrapProgram $out/bin/BeamMP-Launcher \
      --set SSL_CERT_FILE "${cacert_3108}/etc/ssl/certs/ca-bundle.crt"
  '';

  meta = {
    description = "Launcher for the BeamMP mod for BeamNG.drive";
    homepage = "https://github.com/BeamMP/BeamMP-Launcher";
    license = lib.licenses.agpl3Only;
    mainProgram = "BeamMP-Launcher";
    maintainers = with lib.maintainers; [
      Andy3153
      mochienya
    ];
    platforms = lib.platforms.linux;
  };
})
