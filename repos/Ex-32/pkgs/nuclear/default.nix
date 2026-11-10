{
  lib,
  stdenv,
  aws-lc,
  cacert,
  cargo-tauri,
  desktop-file-utils,
  fetchFromGitHub,
  fetchPnpmDeps,
  glib-networking,
  nodejs,
  pnpm_11,
  pnpmConfigHook,
  pkg-config,
  rustPlatform,
  sqlite,
  webkitgtk_4_1,
  wrapGAppsHook4,
  zstd,
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

  # Vendored from packages/player/src-tauri/Cargo.lock at the pinned tag to
  # avoid an import-from-derivation: NUR's CI check
  # (`nix-env -f . -qa --drv-path`) evaluates read-only, so no .drv is ever
  # written and the string-context IFD fails with
  #   error: path '...-source.drv' is not valid
  # Refresh on version bumps:
  #   curl -o pkgs/nuclear/Cargo.lock https://raw.githubusercontent.com/nukeop/nuclear/player%40<version>/packages/player/src-tauri/Cargo.lock
  # fix-path-env-rs is a git dependency with no crates.io release, hence the
  # output hash below.
  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes."fix-path-env-0.0.0" =
      "sha256-UygkxJZoiJlsgp8PLf1zaSVsJZx1GGdQyTXqaFv3oGk=";
  };

  # pnpmDeps.hash is tied to the pnpm major that produced the store, and
  # nixos-26.05 ships pnpm 11 while unstable ships pnpm 12. Pin pnpm_11
  # (11.27.0 on both) so one hash covers every channel in CI's matrix.
  pnpmDeps = fetchPnpmDeps {
    pname = finalAttrs.pname;
    inherit (finalAttrs) src;
    pnpm = pnpm_11;
    fetcherVersion = 5;
    hash = "sha256-aALhI/YYru6CAOiUXmpBKr5UYYVhKjHyXrYILTYLFug=";
  };

  # The workspace root is the tauri app; vite needs the whole monorepo on disk
  pnpmRoot = ".";

  nativeBuildInputs = [
    cacert
    cargo-tauri.hook
    desktop-file-utils
    nodejs
    pkg-config
    pnpm_11
    pnpmConfigHook
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    wrapGAppsHook4
  ];

  # nixpkgs' cargoSetupHook forces crates onto system libraries
  # (nixpkgs #537108): rustls needs aws-lc, sqlx needs sqlite, and zstd needs
  # zstd, instead of each crate's vendored copy.
  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    aws-lc
    glib-networking
    sqlite
    webkitgtk_4_1
    zstd
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
