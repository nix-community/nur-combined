{
  lib,
  rustPlatform,
  stdenv,
  fetchFromGitHub,

  cargo-tauri,
  fetchNpmDeps,
  npmHooks,
  nodejs,
  pkg-config,
  wrapGAppsHook4,

  glib,
  libayatana-appindicator,
  librsvg,
  openssl,
  webkitgtk_4_1,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "dev-manager-desktop";
  version = "1.99.16";

  src = fetchFromGitHub {
    owner = "webosbrew";
    repo = "dev-manager-desktop";
    tag = "v${finalAttrs.version}";
    hash = "sha256-mWqPEAQW59HRDoV3JEosAxe3IrFgSihWB0Joz1rpdh8=";
  };

  npmDeps = fetchNpmDeps {
    name = "${finalAttrs.pname}-${finalAttrs.version}-npm-deps";
    inherit (finalAttrs) src;
    hash = "sha256-YYm8nZ5eKoy1kx28oA2buocQB3bZ6IGWV48pYDJZR4g=";
  };

  cargoHash = "sha256-a6H7MEHNkOOfw1VdvYQ/ZN8myVcBIk8fdm6LUHUYOAg=";

  nativeBuildInputs = [
    cargo-tauri.hook
    npmHooks.npmConfigHook
    nodejs
    pkg-config
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [ wrapGAppsHook4 ];

  buildInputs = [
    glib
    libayatana-appindicator
    librsvg
    openssl
    webkitgtk_4_1
  ];

  checkFlags = [
    # test requires networking?
    "--skip=conn_pool::cmd::test::execute_command_timeout"

    # tests requiring Docker
    "--skip=conn_pool::cmd::test::execute_command_wrongpass"
    "--skip=conn_pool::cmd::test::execute_command_whoami_keyauth"
    "--skip=conn_pool::cmd::test::execute_command_false"
    "--skip=conn_pool::cmd::test::execute_command_noauth"
    "--skip=conn_pool::cmd::test::execute_command_whoami"
  ];

  preFixup = ''
    # https://github.com/tauri-apps/tauri/issues/10702
    gappsWrapperArgs+=(--set-default __NV_DISABLE_EXPLICIT_SYNC 1)
  '';

  meta = {
    description = "Simple tool to manage developer mode enabled or rooted webOS TV";
    license = lib.licenses.asl20;
    homepage = "https://github.com/webosbrew/dev-manager-desktop";
    mainProgram = "webos-dev-manager";
  };
})
