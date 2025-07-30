{
  lib,
  stdenv,
  rustPlatform,
  fetchNpmDeps,
  cargo-tauri,
  copyDesktopItems,
  glib-networking,
  libayatana-appindicator,
  nodejs,
  npmHooks,
  openssl,
  pkg-config,
  webkitgtk_4_1,
  wrapGAppsHook4,
  fetchFromGitHub,
  jq,
  moreutils,
}:

rustPlatform.buildRustPackage rec {
  pname = "zju-learning-assistant";
  version = "0.3.11";
  src = fetchFromGitHub {
    owner = "PeiPei233";
    repo = "zju-learning-assistant";
    rev = "v${version}";
    hash = "sha256-3LLIYT0JRosxy1clN4aLY0ECmnGFsVu2wfeGR3h3r4c=";
  };

  cargoHash = "sha256-GRV7Ji+ox0YJvfPX4PcbJGz0VwxxE9L2iK/VaHU/SAo=";

  npmDeps = fetchNpmDeps {
    name = "${pname}-npm-deps-${version}";
    inherit src;
    hash = "sha256-NHrc1Ci9BSemHsY3Fa6Fu5v4SbRK4Zd/GQTrPmKEFs0=";
  };

  nativeBuildInputs = [
    cargo-tauri.hook
    nodejs
    npmHooks.npmConfigHook

    pkg-config
    wrapGAppsHook4
    copyDesktopItems

    jq
    moreutils
  ];

  buildInputs = [
    openssl
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    glib-networking
    libayatana-appindicator
    webkitgtk_4_1
  ];

  cargoRoot = "src-tauri";
  buildAndTestSubdir = cargoRoot;

  # from https://github.com/NixOS/nixpkgs/blob/04e40bca2a68d7ca85f1c47f00598abb062a8b12/pkgs/by-name/ca/cargo-tauri/test-app.nix#L23-L26
  postPatch = ''
    substituteInPlace $cargoDepsCopy/libappindicator-sys-*/src/lib.rs \
      --replace-fail "libayatana-appindicator3.so.1" "${libayatana-appindicator}/lib/libayatana-appindicator3.so.1"
    jq \
    '.bundle.createUpdaterArtifacts = false' \
    src-tauri/tauri.conf.json \
    | sponge src-tauri/tauri.conf.json
  '';

  meta = {
    homepage = "https://github.com/PeiPei233/zju-learning-assistant";
    changelog = "https://github.com/PeiPei233/zju-learning-assistant/releases/tag/v${version}";
    description = "帮你快速下载所有课件😋";
    mainProgram = "zju-learning-assistant";
    license = lib.licenses.mit;
  };
}
