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
  version = "2.5.1";
  structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "TwintailTeam";
    repo = "TwintailLauncher";
    tag = "ttl-v${finalAttrs.version}";
    hash = "sha256-A8A8Rn4dSE0ABvFD8VOeo83bgOOhChZPr/rn0tpx2F0=";
  };

  cargoHash = "sha256-Nm9jiHaI5frTBIGKe/gagZuAPkAeci0KP0eycU91anM=";

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    inherit pnpm;
    fetcherVersion = 4;
    hash = "sha256-lpqberANUFYlPKn83WeK2H5owlODjxEKxgU8aw1q6to=";
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
      # For some reasons ttl cannot find the lib at runtime even if it's required to build
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
