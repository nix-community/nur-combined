{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitea,
  pkg-config,
  gtk4,
  openssl,
  wrapGAppsHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "eva";
  version = "0.4.1";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "jeang3nie";
    repo = "eva";
    tag = "v${finalAttrs.version}";
    hash = "sha256-beCILpBqW8kHcLkW3q6LRRduDTMDwsqnXUEkZbX9hL4=";
  };

  cargoPatches = [ ./cargo-lock.patch ];
  cargoHash = "sha256-e4P05TFjAaCQr5Pm5r4ZOK7y4eUxyQ/fp/m6DzjfHvo=";

  nativeBuildInputs = [
    pkg-config
    wrapGAppsHook
  ];

  buildInputs = [
    gtk4
    openssl
  ];

  meta = {
    description = "Gemini protocol browser written in Rust using the gtk+ toolkit";
    homepage = "https://codeberg.org/jeang3nie/eva";
    license = lib.licenses.gpl3;
    maintainers = [ lib.maintainers.sikmir ];
  };
})
