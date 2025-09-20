{
  maintainers-list,

  lib,
  stdenv,
  rustPlatform,
  fetchYarnDeps,
  cargo-tauri,
  jq,
  moreutils,
  glib-networking,
  nodejs,
  yarnConfigHook,
  openssl,
  pkg-config,
  webkitgtk_4_1,
  wrapGAppsHook,
  fetchFromGitHub,
  libayatana-appindicator
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "noriskclient-launcher-unwrapped";
  version = "0.6.8";
  src = fetchFromGitHub {
    owner = "NoRiskClient";
    repo = "noriskclient-launcher";
    rev = "v${finalAttrs.version}";
    hash = "sha256-T33y9I6FXmrleLDBxTVMIQK35fZAgDgrKcb02ABAt+E=";
    fetchSubmodules = true;
  };

  cargoHash = "sha256-0vVN2vJW+hrjQeTEw3L8JKa4/C83sCtxNJEaTkwwbT8=";

  yarnOfflineCache = fetchYarnDeps {
    yarnLock = finalAttrs.src + "/yarn.lock";
    hash = "sha256-MEdT/1jPtt9PIMGzBaiji67UUqwDi+vF//w9cAvtOBk=";
  };

  nativeBuildInputs = [
    cargo-tauri.hook
    jq
    moreutils
    nodejs
    yarnConfigHook
    pkg-config
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [ wrapGAppsHook ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    glib-networking
    openssl
    webkitgtk_4_1
    libayatana-appindicator
  ];

  cargoRoot = "src-tauri";
  buildAndTestSubdir = finalAttrs.cargoRoot;

  # thank you to whoever wrote https://github.com/NixOS/nixpkgs/blob/04e40bca2a68d7ca85f1c47f00598abb062a8b12/pkgs/by-name/ca/cargo-tauri/test-app.nix#L23-L26
  # thank you donovanglover your code in that pull request you made to nixpkgs was very useful
  postPatch = ''
    substituteInPlace $cargoDepsCopy/libappindicator-sys-*/src/lib.rs \
      --replace "libayatana-appindicator3.so.1" "${libayatana-appindicator}/lib/libayatana-appindicator3.so.1"
    jq \
      '.plugins.updater.endpoints = [ ]
      | .bundle.createUpdaterArtifacts = false' \
      src-tauri/tauri.conf.json \
      | sponge src-tauri/tauri.conf.json
  '';

  meta = {
    description = "Launcher for the NoRiskClient PvP client for Minecraft";
    branch = "v3";
    homepage = "https://norisk.gg/";
    downloadPage = "https://github.com/";
    maintainers = [
      maintainers-list.JuxGD
    ];
    sourceProvenance = [ lib.sourceTypes.fromSource ];
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
    mainProgram = "noriskclient-launcher-v3";
    broken = true; # set as broken since it can't actually launch Minecraft
  };
})
