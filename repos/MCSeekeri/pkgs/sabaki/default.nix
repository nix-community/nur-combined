{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  electron_42,
  makeWrapper,
  makeDesktopItem,
  copyDesktopItems,
}:

buildNpmPackage (finalAttrs: {
  pname = "sabaki";
  version = "0.60.2";

  src = fetchFromGitHub {
    owner = "SabakiHQ";
    repo = "Sabaki";
    tag = "v${finalAttrs.version}";
    hash = "sha256-DoP5KZiaf+HYwbmg/im5UawkVwPg1rTVrX3ox5GZc9s=";
  };

  npmDepsHash = "sha256-KalPH3nGccAnLMGm+mNEmQEt/ucszbYdBoE0VWJqlEk=";
  ELECTRON_SKIP_BINARY_DOWNLOAD = "1";

  nativeBuildInputs = [
    makeWrapper
    copyDesktopItems
  ];

  npmBuildScript = "bundle";

  installPhase = ''
    runHook preInstall

    npm prune --omit=dev
    mkdir -p $out/lib/sabaki
    cp -r . $out/lib/sabaki/app
    install -Dm644 logo.png $out/share/icons/hicolor/512x512/apps/sabaki.png
    makeWrapper ${electron_42}/bin/electron $out/bin/sabaki \
      --add-flags "--app=$out/lib/sabaki/app"

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "sabaki";
      desktopName = "Sabaki";
      comment = "Cross-platform Go/Baduk board and SGF editor";
      exec = "sabaki %F";
      icon = "sabaki";
      categories = [
        "Game"
        "BoardGame"
      ];
      mimeTypes = [
        "application/x-go-sgf"
        "application/x-go-ngf"
      ];
    })
  ];

  meta = {
    description = "Cross-platform Go/Baduk board and SGF editor";
    homepage = "https://sabaki.yichuanshen.de/";
    changelog = "https://github.com/SabakiHQ/Sabaki/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    mainProgram = "sabaki";
    platforms = lib.platforms.linux;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    maintainers = with lib.maintainers; [ MCSeekeri ];
  };
})
