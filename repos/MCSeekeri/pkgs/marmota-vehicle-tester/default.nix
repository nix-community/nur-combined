{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  wrapGAppsHook3,
  copyDesktopItems,
  makeDesktopItem,
  gtk3,
  webkitgtk_4_1,
  librsvg,
  sqlite,
  nix-update-script,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "marmota-vehicle-tester";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "f05135";
    repo = "Marmota-Vehicle-Tester";
    tag = "v${finalAttrs.version}";
    sparseCheckout = [
      "Cargo.lock"
      "Cargo.toml"
      "LICENSE"
      "build.rs"
      "packaging"
      "src"
      "ui"
    ];
    hash = "sha256-71mP3Vc5xfWlPdNpzrzrE34cd1hVc2lCHyvalzNkgGs=";
  };

  cargoHash = "sha256-chCu0r9cBEo71mfrAZ2mwZJZVJXDDUfC6jMs0WRKhSc=";

  postPatch = ''
    substituteInPlace src/config.rs \
      --replace-fail 'content/pkg_local/gameData' 'content/pkg_local/gamedata'
    substituteInPlace src/core/vehicle_generator.rs \
      --replace-fail 'gameData' 'gamedata'
    substituteInPlace src/core/vehicle_classifier.rs \
      --replace-fail 'gameData' 'gamedata'
  '';

  nativeBuildInputs = [
    copyDesktopItems
    pkg-config
    wrapGAppsHook3
  ];

  buildInputs = [
    gtk3
    webkitgtk_4_1
    librsvg
    sqlite
  ];

  doCheck = false;

  postInstall = ''
    install -Dm644 ui/branding/logo.png $out/share/icons/hicolor/512x512/apps/marmota-vehicle-tester.png
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "marmota-vehicle-tester";
      desktopName = "Marmota Vehicle Tester";
      comment = "War Thunder vehicle inspector and UserMissions loadout manager";
      exec = "marmota_vehicle_tester";
      icon = "marmota-vehicle-tester";
      categories = [
        "Utility"
        "Game"
      ];
    })
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "War Thunder vehicle inspector, loadout configurator and local UserMissions injector";
    homepage = "https://github.com/f05135/Marmota-Vehicle-Tester";
    changelog = "https://github.com/f05135/Marmota-Vehicle-Tester/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Plus;
    mainProgram = "marmota_vehicle_tester";
    platforms = lib.platforms.linux;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    maintainers = with lib.maintainers; [ MCSeekeri ];
  };
})
