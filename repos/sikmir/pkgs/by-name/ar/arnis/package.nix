{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  copyDesktopItems,
  makeDesktopItem,
  pkg-config,
  gtk3,
  openssl,
  webkitgtk_4_1,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "arnis";
  version = "2.5.0";

  src = fetchFromGitHub {
    owner = "louis-e";
    repo = "arnis";
    tag = "v${finalAttrs.version}";
    hash = "sha256-LDFzoUNA0LxiiupxFNG932fewGFWfdp948hcULzUExY=";
  };

  cargoHash = "sha256-/laozHkeoig/pnzApn0hae/78XL48UAhTMtkvFlxICU=";

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    copyDesktopItems
    pkg-config
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    gtk3
    openssl
    webkitgtk_4_1
  ];

  desktopItems = [
    (makeDesktopItem {
      name = "arnis";
      type = "Application";
      desktopName = "Arnis";
      comment = "Generate cities from real life in Minecraft";
      exec = "arnis";
      icon = "arnis";
      terminal = false;
      startupWMClass = "arnis";
      categories = [
        "Game"
        "Utility"
        "Geoscience"
      ];
    })
  ];

  checkFlags = [
    # requires network access
    "--skip=map_transformation::translate::translator::tests::test_translate_by_vector"
  ];

  postInstall = lib.optionalString stdenv.hostPlatform.isLinux ''
    install -Dm644 assets/icons/icon.png $out/share/icons/hicolor/512x512/apps/arnis.png
    install -Dm644 assets/icons/128x128.png $out/share/icons/hicolor/128x128/apps/arnis.png
  '';

  meta = {
    description = "Generate real life cities in Minecraft";
    homepage = "https://github.com/louis-e/arnis";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.sikmir ];
    mainProgram = "arnis";
  };
})
