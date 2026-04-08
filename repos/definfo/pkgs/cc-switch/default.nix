{
  lib,
  rustPlatform,
  fetchFromGitHub,
  fetchPnpmDeps,
  pnpmConfigHook,
  pnpm_10,
  pkg-config,
  cargo-tauri,
  wrapGAppsHook3,
  nodejs,
  openssl,
  libsoup_3,
  webkitgtk_4_1,
  libayatana-appindicator,
  jq,
  moreutils,
  nix-update-script,
}:
let
  pnpm = pnpm_10.override { inherit nodejs; };
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cc-switch";
  version = "3.12.3";

  src = fetchFromGitHub {
    owner = "farion1231";
    repo = "cc-switch";
    tag = "v${finalAttrs.version}";
    hash = "sha256-+gHxOAumI/ZUukFNc9ks22bkqbOky6F7MYZzGwrXRRc=";
  };

  patches = [
    ./0001-fix-match-tauri-deps-version-between-NPM-Rust.patch
  ];

  cargoLock = {
    lockFileContents = builtins.readFile ./Cargo.lock;
  };

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src patches;
    inherit pnpm;
    fetcherVersion = 3;
    hash = "sha256-KrE22BMYN2Yl/AlHJYc8WRVaFEwFWZBk6cbvwKhV/Qo=";
  };

  postPatch = ''
    substituteInPlace $cargoDepsCopy/libappindicator-sys-*/src/lib.rs \
      --replace-fail "libayatana-appindicator3.so.1" "${libayatana-appindicator}/lib/libayatana-appindicator3.so.1"

    ${lib.getExe jq} '
      .bundle = (.bundle // {}) |
      .bundle.createUpdaterArtifacts = false |
      del(.plugins.updater)
    ' src-tauri/tauri.conf.json \
      | ${lib.getExe' moreutils "sponge"} src-tauri/tauri.conf.json
  '';

  nativeBuildInputs = [
    cargo-tauri.hook
    pkg-config
    pnpmConfigHook
    rustPlatform.bindgenHook
    wrapGAppsHook3
    nodejs
    pnpm
  ];

  buildInputs = [
    openssl
    libsoup_3
    webkitgtk_4_1
    libayatana-appindicator
  ];

  checkFlags = map (t: "--skip ${t}") [
    # need network connection
  ];

  # Set our Tauri source directory
  cargoRoot = "src-tauri";
  # And make sure we build there too
  buildAndTestSubdir = finalAttrs.cargoRoot;

  passthru.updateScript = nix-update-script { extraArgs = [ "--version-regex=v(.*)" ]; };

  meta = {
    description = "An assistant tool for SJTU Canvas online course platform";
    homepage = "https://github.com/Okabe-Rintarou-0/SJTU-Canvas-Helper";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    maintainers = with lib.maintainers; [ definfo ];
  };
})
