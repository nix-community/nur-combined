{
  lib,
  cargo-tauri,
  fetchFromGitHub,
  fetchPnpmDeps,
  fontconfig,
  freetype,
  glib-networking,
  libayatana-appindicator,
  nix-update-script,
  nodejs,
  openssl,
  pkg-config,
  pnpmConfigHook,
  pnpm,
  rustPlatform,
  udev,
  webkitgtk_4_1,
  wrapGAppsHook3,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "nyaterm";
  version = "1.1.18";

  src = fetchFromGitHub {
    owner = "nyakang";
    repo = "nyaterm";
    tag = "v${finalAttrs.version}";
    hash = "sha256-DUfoNsZSdTILeL9Qc3QVuaT/wilUpsDPgS6h2G1XMZg=";
  };

  # Use cargoLock (like pkgs/meatshell) instead of cargoHash: the lockfile
  # lives inside src, so version bumps need no extra cargo hash maintenance.
  cargoLock.lockFile = "${finalAttrs.src}/src-tauri/Cargo.lock";
  cargoRoot = "src-tauri";
  buildAndTestSubdir = "src-tauri";

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    pnpm = pnpm;
    fetcherVersion = 3;
    hash = "sha256-vqqnWaNv75VVANnqq2cA7Eske6nVZtix2ZfuJwc+seQ=";
  };

  nativeBuildInputs = [
    cargo-tauri.hook
    nodejs
    pkg-config
    pnpmConfigHook
    pnpm
    wrapGAppsHook3
  ];

  buildInputs = [
    fontconfig
    freetype
    glib-networking
    libayatana-appindicator
    openssl
    udev
    webkitgtk_4_1
  ];

  postPatch = ''
    # Updater artifacts need the private signing key, only available in upstream CI
    substituteInPlace src-tauri/tauri.conf.json \
      --replace-fail '"createUpdaterArtifacts": true' '"createUpdaterArtifacts": false'
  '';

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ libayatana-appindicator ]}"
    )
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Modern remote terminal workspace with SSH, SFTP and AI assistance";
    homepage = "https://github.com/nyakang/nyaterm";
    changelog = "https://github.com/nyakang/nyaterm/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    mainProgram = "nyaterm";
    platforms = lib.platforms.linux;
  };
})
