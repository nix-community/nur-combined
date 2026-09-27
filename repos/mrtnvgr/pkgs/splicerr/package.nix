{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchPnpmDeps,
  cargo-tauri,
  rustPlatform,
  nodejs,
  pnpm_10,
  pnpmConfigHook,
  pkg-config,
  glib-networking,
  libayatana-appindicator,
  openssl,
  webkitgtk_4_1,
  wrapGAppsHook4,
}:

let
  pnpm = pnpm_10;
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "splicerr";
  version = "1.0.13";

  src = fetchFromGitHub {
    owner = "Exorsky";
    repo = "splicerr";
    tag = "v${finalAttrs.version}";
    hash = "sha256-cOXGswc8yBUcE4jc6mDEBkhLMPnDvp7Ma5FQ2zs+vvQ=";
  };

  cargoHash = "sha256-U4Lyzm+VcbSh4c63wjhncYR63Hgj0jZhKYOBHoxQRP8=";

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    inherit pnpm;
    fetcherVersion = 4;
    hash = "sha256-pgTWdQ9C0rWa2Fag78RZZFEIHsEWae9n0eW9yJfdBuo=";
  };

  postPatch = lib.optionalString stdenv.hostPlatform.isLinux ''
    substituteInPlace $cargoDepsCopy/*/libappindicator-sys-*/src/lib.rs \
      --replace-fail libayatana-appindicator3.so.1 '${libayatana-appindicator}/lib/libayatana-appindicator3.so.1'
  '';

  cargoRoot = "src-tauri";
  buildAndTestSubdir = finalAttrs.cargoRoot;

  nativeBuildInputs = [
    cargo-tauri.hook
    nodejs
    pnpm
    pnpmConfigHook
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    pkg-config
    wrapGAppsHook4
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    glib-networking
    libayatana-appindicator
    openssl
    webkitgtk_4_1
  ];

  meta = {
    description = "Custom frontend for the Splice sample library";
    homepage = "https://github.com/Exorsky/splicerr";
    license = lib.licenses.mit;
    mainProgram = "splicerr";
    platforms = lib.platforms.linux;
  };
})
