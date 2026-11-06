{
  lib,
  rustPlatform,
  fetchFromGitHub,
  cargo-tauri,
  pkg-config,
  wrapGAppsHook4,
  glib-networking,
  openssl,
  webkitgtk_4_1,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "mixedupmh";
  version = "0.8.0";

  src = fetchFromGitHub {
    owner = "farbzen";
    repo = "mixedupmh";
    tag = "v${finalAttrs.version}";
    hash = "sha256-zGs+dV7ty8+/DBLeey+5jlG6Lmbnjzo65ftTWvSKPww=";
  };

  cargoHash = "sha256-XPtseVwxCCbwY+RonazJEn9A5JBlwb4zX6yYoAgsD7Q=";

  nativeBuildInputs = [
    cargo-tauri.hook
    pkg-config
    wrapGAppsHook4
  ];

  buildInputs = [
    glib-networking
    openssl
    webkitgtk_4_1
  ];

  meta = {
    description = "Randomizer for Monster Hunter Wilds that rolls monsters and weapons for your hunting party";
    homepage = "https://github.com/farbzen/mixedupmh";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "mumh";
    maintainers = [
      {
        email = "dev@farbzen.de";
        github = "farbzen";
        githubId = 60570640;
        name = "Fabian Meier";
      }
    ];
  };
})
