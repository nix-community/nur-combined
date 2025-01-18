{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  fetchYarnDeps,
  cargo-tauri_1, # ! tauri_cli for Tauri v1
  darwin,
  glib-networking,
  nodejs,
  yarnConfigHook,
  openssl,
  libsoup,
  pkg-config,
  webkitgtk_4_0,
  wrapGAppsHook3,
  desktop-file-utils,
}:

rustPlatform.buildRustPackage rec {
  pname = "sjtu-canvas-helper";
  version = "1.3.24";

  src = fetchFromGitHub {
    owner = "Okabe-Rintarou-0";
    repo = "SJTU-Canvas-Helper";
    tag = "app-v${version}";
    hash = "sha256-DE4qL2dbUqTIIpjiWssKnBRSRtXbl7hTQv8zMZKNw/A=";
  };
  
  useFetchCargoVendor = true;

  cargoHash = "sha256-VQlRKNqpg1MA0tCZiICJ899QsV+H6rJGedK+feRiZkA=";

  yarnOfflineCache = fetchYarnDeps {
    yarnLock = src + "/yarn.lock";
    hash = "sha256-ARr9KdUamHpXQR9qmJ/upmVhSIltzim0pLUbR8Wgkik=";
  };

  nativeBuildInputs = [
    # Pull in our main hook
    cargo-tauri_1.hook
    rustPlatform.bindgenHook

    # Setup yarn
    nodejs
    yarnConfigHook

    # Make sure we can find our libraries
    pkg-config
    wrapGAppsHook3

    desktop-file-utils
  ];

  buildInputs =
    [
      openssl
    ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [
      glib-networking # Most Tauri apps need networking
      libsoup
      webkitgtk_4_0
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin (
      with darwin.apple_sdk.frameworks;
      [
        AppKit
        CoreServices
        Security
        WebKit
      ]
    );

  env.OPENSSL_NO_VENDOR = 1;

  doCheck = false;

  postInstall = lib.optionalString stdenv.hostPlatform.isLinux ''
    desktop-file-edit \
      --set-key="Categories" --set-value="Utility" \
      $out/share/applications/sjtu-canvas-helper.desktop
  '';

  # Set our Tauri source directory
  cargoRoot = "src-tauri";
  # And make sure we build there too
  buildAndTestSubdir = cargoRoot;

  meta = {
    description = "An assistant tool for SJTU Canvas online course platform";
    homepage = "https://github.com/Okabe-Rintarou-0/SJTU-Canvas-Helper";
    license = lib.licenses.unlicense;
    maintainers = with lib.maintainers; [ definfo ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
}
