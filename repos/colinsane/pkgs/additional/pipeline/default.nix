{ lib
, stdenv
, cargo
, desktop-file-utils
, fetchFromGitLab
, libadwaita
, meson
, ninja
, openssl
, pkg-config
, rustPlatform
, rustc
, wrapGAppsHook4
}:

stdenv.mkDerivation rec {
  pname = "pipeline";
  version = "1.14.1";

  src = fetchFromGitLab {
    domain = "gitlab.com";
    owner = "schmiddi-on-mobile";
    repo = "pipeline";
    rev = "v${version}";
    hash = "sha256-CQFxNA6gC5mUdyFbf/oMK5kLtzRhglXCDHnyb9XQOSg=";
  };

  cargoDeps = rustPlatform.importCargoLock {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "tf_core-0.1.4" = "sha256-bWkF1ezdDZyuP2zo5EIvB/Br6HFpdmkDijpQii/4i68=";
    };
  };

  nativeBuildInputs = [
    cargo
    desktop-file-utils
    meson
    ninja
    pkg-config
    rustPlatform.cargoSetupHook
    rustc
    wrapGAppsHook4
  ];

  buildInputs = [
    libadwaita
    openssl
  ];

  meta = {
    changelog = "https://gitlab.com/schmiddi-on-mobile/pipeline/-/blob/${src.rev}/CHANGELOG.md";
    description = "Watch YouTube and PeerTube videos in one place";
    homepage = "https://gitlab.com/schmiddi-on-mobile/pipeline";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ colinsane ];
    platforms = lib.platforms.linux;
    mainProgram = "tubefeeder";
  };
}

