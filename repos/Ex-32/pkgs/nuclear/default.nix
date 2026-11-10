{
  lib,
  stdenv,
  cacert,
  cargo-tauri,
  desktop-file-utils,
  fetchFromGitHub,
  fetchPnpmDeps,
  glib-networking,
  nodejs,
  pnpm,
  pnpmConfigHook,
  pkg-config,
  rustPlatform,
  webkitgtk_4_1,
  wrapGAppsHook4,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "nuclear";
  version = "1.54.2";

  src = fetchFromGitHub {
    owner = "nukeop";
    repo = "nuclear";
    rev = "player@${finalAttrs.version}";
    hash = "sha256-DdDmYtMCgKSVne0dFMgLDFK93sfWvxPCHFd9nFeKydI=";
  };

  # fix-path-env-rs is a git dependency with no crates.io release; the
  # lockfile is read straight out of src (single interpolation IFD)
  cargoLock = {
    lockFile = "${finalAttrs.src}/packages/player/src-tauri/Cargo.lock";
    outputHashes."fix-path-env-0.0.0" =
      "sha256-UygkxJZoiJlsgp8PLf1zaSVsJZx1GGdQyTXqaFv3oGk=";
  };

  pnpmDeps = fetchPnpmDeps {
    pname = finalAttrs.pname;
    inherit (finalAttrs) src;
    fetcherVersion = 5;
    hash = "sha256-UBUFb+smJA/FQy6TmsXzaCgsFb/m6inSUBa7Qn2/NOk=";
  };

  # The workspace root is the tauri app; vite needs the whole monorepo on disk
  pnpmRoot = ".";

  nativeBuildInputs = [
    cacert
    cargo-tauri.hook
    desktop-file-utils
    nodejs
    pkg-config
    pnpm
    pnpmConfigHook
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    wrapGAppsHook4
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    glib-networking
    webkitgtk_4_1
  ];

  cargoRoot = "packages/player/src-tauri";
  buildAndTestSubdir = finalAttrs.cargoRoot;

  # Upstream enables createUpdaterArtifacts; without a TAURI_SIGNING_PRIVATE_KEY
  # the CLI fails right after bundling. Inline config override keeps the
  # nixpkgs tree free of extra files.
  tauriBuildFlags = [
    "--config"
    (builtins.toJSON {
      bundle.createUpdaterArtifacts = false;
    })
  ];

  postInstall = lib.optionalString stdenv.hostPlatform.isLinux ''
    desktop-file-edit \
      --set-key="StartupWMClass" --set-value="nuclear music player" \
      $out/share/applications/Nuclear.desktop
  '';

  meta = {
    homepage = "https://nuclearplayer.com/";
    description = "Streaming music player that finds free music for you";
    changelog = "https://github.com/nukeop/nuclear/releases/tag/player@${finalAttrs.version}";
    longDescription = ''
      Nuclear is a free, open-source music player without ads or tracking.
      Search for any song or artist, build playlists, and start listening.
    '';
    license = lib.licenses.agpl3Only;
    platforms = lib.platforms.linux;
    mainProgram = "nuclear-music-player";
  };
})
