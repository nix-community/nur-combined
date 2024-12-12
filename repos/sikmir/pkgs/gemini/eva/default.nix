{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitea,
  pkg-config,
  gtk4,
  openssl,
  wrapGAppsHook,
  darwin,
}:

rustPlatform.buildRustPackage rec {
  pname = "eva";
  version = "0.4.1";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "jeang3nie";
    repo = "eva";
    tag = "v${version}";
    hash = "sha256-beCILpBqW8kHcLkW3q6LRRduDTMDwsqnXUEkZbX9hL4=";
  };

  cargoPatches = [ ./cargo-lock.patch ];
  cargoHash = "sha256-BFRowucvjYzCF7au4O/Q/lSpgaNUpNDx3OhnbwwfF24=";

  nativeBuildInputs = [
    pkg-config
    wrapGAppsHook
  ];

  buildInputs = [
    gtk4
    openssl
  ] ++ lib.optional stdenv.isDarwin darwin.apple_sdk.frameworks.Security;

  meta = {
    description = "Gemini protocol browser written in Rust using the gtk+ toolkit";
    homepage = "https://codeberg.org/jeang3nie/eva";
    license = lib.licenses.gpl3;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
