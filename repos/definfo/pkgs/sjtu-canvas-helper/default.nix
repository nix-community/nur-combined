{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  fetchYarnDeps,
  cargo-tauri,
  glib-networking,
  nodejs,
  yarnConfigHook,
  openssl,
  libsoup_3,
  pkg-config,
  webkitgtk_4_1,
  wrapGAppsHook3,
  desktop-file-utils,
  jq,
  moreutils,
  nix-update-script,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "sjtu-canvas-helper";
  version = "2.0.4";

  src = fetchFromGitHub {
    owner = "Okabe-Rintarou-0";
    repo = "SJTU-Canvas-Helper";
    tag = "app-v${finalAttrs.version}";
    hash = "sha256-O50nVE0AzXDmNUiilwOswivuGJKUrDJVquIumcPP6d4=";
  };

  cargoHash = "sha256-RPWhGLs36ODfphC6nO+72m+dV71kQ7MWvgDqIPCIKBY=";

  yarnOfflineCache = fetchYarnDeps {
    yarnLock = finalAttrs.src + "/yarn.lock";
    hash = "sha256-H3P7ObzOw+Solxk6BJ9ruue63MnUiSK3RszoV0OLZDY=";
  };

  postPatch = lib.optionalString stdenv.hostPlatform.isLinux ''
    ${jq}/bin/jq '.bundle.createUpdaterArtifacts = false' src-tauri/tauri.conf.json | ${moreutils}/bin/sponge src-tauri/tauri.conf.json
  '';

  nativeBuildInputs = [
    cargo-tauri.hook
    nodejs
    pkg-config
    yarnConfigHook
    rustPlatform.bindgenHook
    wrapGAppsHook3
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    desktop-file-utils
  ];

  buildInputs = [
    openssl
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    glib-networking
    libsoup_3
    webkitgtk_4_1
  ];

  env.OPENSSL_NO_VENDOR = 1;

  postInstall = lib.optionalString stdenv.hostPlatform.isLinux ''
    ${desktop-file-utils}/bin/desktop-file-edit \
      --set-key="Categories" --set-value="Utility" \
      $out/share/applications/SJTU\ Canvas\ Helper.desktop
  '';

  checkFlags = builtins.map (t: "--skip ${t}") [
    # need network connection
    "client::basic::test::test_get_me"
    "client::basic::test::test_list_assignments"
    "client::basic::test::test_list_colors"
    "client::basic::test::test_list_courses"
    "client::basic::test::test_list_submissions"
    "client::basic::test::test_list_users"
    "client::video::tests::test_download_video"
    "client::video::tests::test_get_uuid"
  ];

  # Set our Tauri source directory
  cargoRoot = "src-tauri";
  # And make sure we build there too
  buildAndTestSubdir = finalAttrs.cargoRoot;

  passthru.updateScript = nix-update-script { extraArgs = [ "--version-regex=app-v(.*)" ]; };

  meta = {
    description = "An assistant tool for SJTU Canvas online course platform";
    homepage = "https://github.com/Okabe-Rintarou-0/SJTU-Canvas-Helper";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    maintainers = with lib.maintainers; [ definfo ];
  };
})
