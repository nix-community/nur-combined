{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  fetchYarnDeps,
  cargo-tauri_1, # ! tauri_cli for Tauri v1
  glib-networking,
  nodejs,
  yarnConfigHook,
  openssl,
  libsoup_2_4,
  pkg-config,
  webkitgtk_4_0,
  wrapGAppsHook3,
  desktop-file-utils,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "sjtu-canvas-helper";
  version = "1.3.33";

  src = fetchFromGitHub {
    owner = "Okabe-Rintarou-0";
    repo = "SJTU-Canvas-Helper";
    tag = "app-v${finalAttrs.version}";
    hash = "sha256-C0LMeXkwHduTDYHjC6077mPBFERaS65rM+ikEsupVwE=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-j86GBAjVJJ+wqqqtWMJIrAmP4wvcgsen70C7D1A5IXU=";

  yarnOfflineCache = fetchYarnDeps {
    yarnLock = finalAttrs.src + "/yarn.lock";
    hash = "sha256-mX2uXonIkiakGLLZhZwNwMWDd45MPnlQIPtX3tVVhWE=";
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
      libsoup_2_4
      webkitgtk_4_0
    ];

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
  buildAndTestSubdir = finalAttrs.cargoRoot;

  meta = {
    description = "An assistant tool for SJTU Canvas online course platform";
    homepage = "https://github.com/Okabe-Rintarou-0/SJTU-Canvas-Helper";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    maintainers = with lib.maintainers; [ definfo ];
  };
})
