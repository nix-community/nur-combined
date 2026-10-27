{ lib
, fetchFromGitHub
, rustPlatform
, pkg-config
, alsa-lib
, playerctl
, copyDesktopItems
, makeDesktopItem
}:

let
  pname = "grimoire";
  version = "0.7.5";
in
rustPlatform.buildRustPackage rec {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "kelsierbot";
    repo = "GrimoireTUI";
    rev = "v${version}";
    hash = "sha256-UPaTWhjbgOaSGPie4yfwDm7SRzMp3G3+r7AD94O7Jpk=";
  };

  cargoHash = "sha256-ZLpRFsKgK6mqcQ5euNAmubJ1ZREQITebswfgYEZLI1M=";

  nativeBuildInputs = [
    pkg-config
    copyDesktopItems
  ];

  buildInputs = [
    alsa-lib
    playerctl
  ];


  postInstall = ''
    install -Dm644 apps/mobile/src-tauri/icons/128x128.png \
      $out/share/icons/hicolor/128x128/apps/grimoire.png
    install -Dm644 apps/mobile/src-tauri/icons/128x128@2x.png \
      $out/share/icons/hicolor/256x256/apps/grimoire.png
    install -Dm644 LICENSE \
      $out/share/licenses/${pname}/LICENSE
    install -Dm644 README.md \
      $out/share/doc/${pname}/README.md
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "grimoire";
      desktopName = "Grimoire";
      comment = "A terminal writing desk for novels";
      exec = "grimoire";
      icon = "grimoire";
      categories = [ "Office" "Utility" ];
    })
  ];

  # There are no tests
  doCheck = false;

  meta = {
    description = "A terminal writing desk for novels";
    homepage = "https://github.com/kelsierbot/GrimoireTUI";
    license = lib.licenses.mit;
    mainProgram = "grimoire";
    maintainers = with lib.maintainers; [ anas ];
    platforms = lib.platforms.unix;
  };
}
