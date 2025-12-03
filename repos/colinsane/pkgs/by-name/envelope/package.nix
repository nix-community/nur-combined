{
  cargo,
  desktop-file-utils,
  fetchFromGitLab,
  glib,
  gtk4,
  lib,
  libadwaita,
  libsoup_3,
  meson,
  ninja,
  nix-update-script,
  openssl,
  pkg-config,
  python3,
  rust,
  rustPlatform,
  rustc,
  stdenv,
  webkitgtk_6_0,
  wrapGAppsHook4,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "envelope";
  version = "0.1.0-unstable-2025-05-17";

  src = fetchFromGitLab {
    domain = "gitlab.gnome.org";
    owner = "felinira";
    repo = "envelope";
    rev = "e2a8a56aa9b68d82486b99790b86322715d2a6db";
    hash = "sha256-osVShCaKKoGhxWCjaYcMkOji8e0oETgDaDpCAfHauwQ=";
  };

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = "sha256-8pK8cw9nYJmmybYRL+PUCK8FvUUPbyFp7oYYF461KPc=";
  };

  nativeBuildInputs = [
    cargo
    desktop-file-utils
    meson
    ninja
    pkg-config
    python3
    rustPlatform.cargoSetupHook
    rustc
    wrapGAppsHook4
  ];

  buildInputs = [
    glib
    gtk4
    libadwaita
    libsoup_3
    openssl
    webkitgtk_6_0
  ];

  postPatch = ''
    patchShebangs --build build-aux/meson-cargo-manifest.py

    substituteInPlace src/meson.build \
      --replace-fail \
        "'src' / rust_target / meson.project_name()" \
        "'src' / '${stdenv.hostPlatform.rust.cargoShortTarget}' / rust_target / meson.project_name()"
  '';

  env."CC_${stdenv.buildPlatform.rust.rustcTarget}" = rust.envVars.ccForBuild;  #< fixes cross build of sql-macros proc-macro
  env.CARGO_BUILD_TARGET = stdenv.hostPlatform.rust.rustcTargetSpec;
  env.OPENSSL_NO_VENDOR = true;  #< speculative, to use the nixos openssl
  env.RUSTC_BOOTSTRAP = 1;  #< fixes 'error[E0554]: `#![feature]` may not be used on the stable release channel'
  # env.LIBSQLITE3_SYS_USE_PKG_CONFIG = 1;  #< TODO: use nixos libsqlite instead of pre-packaged one

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "a mobile-first email client for the GNOME ecosystem";
    homepage = "https://gitlab.gnome.org/felinira/envelope/";
    license = licenses.gpl3Plus;
    maintainers = [ maintainers.colinsane ];
    platforms = platforms.linux;
    mainProgram = "envelope";
  };
})
