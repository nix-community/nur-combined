{
  lib,
  rustPlatform,
  fetchFromGitHub,
  cargo-tauri,
  glib-networking,
  nodejs,
  pnpm,
  pnpmConfigHook,
  fetchPnpmDeps,
  openssl,
  pkg-config,
  webkitgtk_4_1,
  git,
  perl,
  libayatana-appindicator,
  wrapGAppsHook4,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "twintaillauncher-unwrapped";
  version = "2.5.0";
  structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "TwintailTeam";
    repo = "TwintailLauncher";
    tag = "ttl-v${finalAttrs.version}";
    hash = "sha256-/TVT2HtRj9C54sPWGlVdAgt1fZ7exJqlh2F8reyo3hA=";
  };

  cargoHash = "sha256-KRM6oP7G2E+pvlL6u0e/oQp7BzpWXJI8LvMJGGZy5EY=";

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    inherit pnpm;
    fetcherVersion = 4;
    hash = "sha256-q2FYYJ2NabXo5efcaulsdN78+tSaqRIUChIXpomGPx0=";
  };

  # Set our Tauri source directory
  cargoRoot = "src-tauri";
  # And make sure we build there too
  buildAndTestSubdir = finalAttrs.cargoRoot;
  
  nativeBuildInputs = [
    # Pull in our main hook
    cargo-tauri.hook

    # Setup npm
    nodejs
    pnpm
    pnpmConfigHook

    # Make sure we can find our libraries
    pkg-config
    git
    perl
    wrapGAppsHook4
  ];

  buildInputs = [
    glib-networking # Most Tauri apps need networking
    openssl
    webkitgtk_4_1
    libayatana-appindicator
  ];

  preFixup = ''
    gappsWrapperArgs+=(
      # The icon theme is hardcoded.
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ libayatana-appindicator ]}
    )
  '';

  meta = {
    description = "A multi-platform launcher for your anime games.";
    homepage = "twintaillauncher.app";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ claymorwan ];
    mainProgram = "twintaillauncher";
    platforms = lib.platforms.linux;
  };
})
