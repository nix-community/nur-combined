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
  nix-update-script,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "twintaillauncher-unwrapped";
  version = "2.5.2";
  structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "TwintailTeam";
    repo = "TwintailLauncher";
    tag = "ttl-v${finalAttrs.version}";
    hash = "sha256-b8z6i0PTL9IagFDH0B+Y0Hpw1PUI5iwMeOcccfg8yLU=";
  };

  cargoHash = "sha256-EvA3VzB+J8gD+nzf4KCTD2hIvsMOc8JmsVTjsBKazkM=";

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

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version-regex=ttl-v(\\d+\\.\\d+\\.\\d+)" ];
  };

  meta = {
    description = "A multi-platform launcher for your anime games.";
    homepage = "twintaillauncher.app";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ claymorwan ];
    mainProgram = "twintaillauncher";
    platforms = lib.platforms.linux;
  };
})
