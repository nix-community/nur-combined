{
  lib,
  stdenv,
  rustPlatform,
  fetchNpmDeps,
  cargo-tauri,
  copyDesktopItems,
  glib-networking,
  libayatana-appindicator,
  nodejs,
  npmHooks,
  openssl,
  pkg-config,
  webkitgtk_4_1,
  wrapGAppsHook4,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage rec {
  pname = "zju-learning-assistant";
  version = "0.3.8";
  src = fetchFromGitHub {
    owner = "PeiPei233";
    repo = "zju-learning-assistant";
    rev = "v${version}";
    hash = "sha256-rLZg8iW/slNfO8Sm08qUcBWp7hZWw3EKZbl0ZHlS2EY=";
  };

  cargoHash = "sha256-h6jBg17fQXEN3JSkM0c4Ioxt+R9gv7mpAH0lPkPtC6I=";

  npmDeps = fetchNpmDeps {
    name = "${pname}-npm-deps-${version}";
    inherit src;
    hash = "sha256-iwOrpoBHBnvy8F1lFR7o/goGEjZwK/BvlhHHJHVv2LY=";
  };

  nativeBuildInputs = [
    cargo-tauri.hook
    nodejs
    npmHooks.npmConfigHook

    pkg-config
    wrapGAppsHook4
    copyDesktopItems
  ];

  buildInputs =
    [ openssl ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [
      glib-networking
      libayatana-appindicator
      webkitgtk_4_1
    ];

  cargoRoot = "src-tauri";
  buildAndTestSubdir = cargoRoot;

  postPatch = lib.optionalString stdenv.hostPlatform.isLinux ''
    # libappindicator-rs need to know where Nix's appindicator lib is.
    pushd $cargoDepsCopy/libappindicator-sys
    oldHash=$(sha256sum src/lib.rs | cut -d " " -f 1)
    substituteInPlace src/lib.rs \
      --replace-fail "libayatana-appindicator3.so.1" "${libayatana-appindicator}/lib/libayatana-appindicator3.so.1"
    # Cargo doesn't like it when vendored dependencies are edited.
    substituteInPlace .cargo-checksum.json \
      --replace-warn $oldHash $(sha256sum src/lib.rs | cut -d " " -f 1)
    popd
  '';

  meta = {
    homepage = "https://github.com/PeiPei233/zju-learning-assistant";
    changelog = "https://github.com/PeiPei233/zju-learning-assistant/releases/tag/v${version}";
    description = "帮你快速下载所有课件😋";
    maintainers = with lib.maintainers; [ ];
    mainProgram = "zju-learning-assistant";
    platforms = [
      "x86_64-linux"
      "aarch64-darwin"
      "x86_64-darwin"
    ];
    license = lib.licenses.mit;
  };
}
