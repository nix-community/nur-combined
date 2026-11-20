{
  lib,
  fetchFromGitHub,
  rustPlatform,
  fetchNpmDeps,
  cargo-tauri,
  npmHooks,
  nodejs,
  pkg-config,
  sqlite,
  zstd,
  cmake,
  git,
  jq,
  nix-update-script,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "antigravity-tools";
  version = "5.0.4";

  src = fetchFromGitHub {
    owner = "lbjlaq";
    repo = "Antigravity-Manager";
    rev = "v${finalAttrs.version}";
    hash = "sha256-QHmurqcoFhX1pgbCjMs29niIGDegz5OIzaeXGbVkNMg=";
  };

  cargoRoot = "src-tauri";
  buildAndTestSubdir = finalAttrs.cargoRoot;

  cargoHash = "sha256-qLgZTq9PF9OrQrm5/ehl3aBaQ9Uh2Btw8bZyn+LMwU0=";
  npmDeps = fetchNpmDeps {
    inherit (finalAttrs) src;
    hash = "sha256-DbhVeZsHkR6juuhREvd6PzC9Cq7GS2CBpFk/bEE0y+A=";
  };

  nativeBuildInputs = [
    cargo-tauri.hook
    npmHooks.npmConfigHook
    nodejs
    pkg-config
    cmake
    git
    jq
    # boring-sys2 generates BoringSSL bindings with bindgen.
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    sqlite
    zstd
  ];

  postPatch = ''
    # No release signing key exists in the sandbox, and Nix users get updates
    # from the flake rather than the upstream updater endpoints.
    jq '
      .bundle.createUpdaterArtifacts = false |
      .plugins.updater = { active: false, pubkey: "", endpoints: [] }
    ' src-tauri/tauri.conf.json > tauri.conf.json.tmp
    mv tauri.conf.json.tmp src-tauri/tauri.conf.json
  '';

  # Upstream's tests hit the network and the user's Antigravity installation.
  doCheck = false;

  postInstall = ''
    mkdir -p $out/bin
    ln -s "$out/Applications/Antigravity Tools.app/Contents/MacOS/antigravity-tools" \
      $out/bin/antigravity-tools
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Antigravity account manager and switcher";
    homepage = "https://github.com/lbjlaq/Antigravity-Manager";
    downloadPage = "https://github.com/lbjlaq/Antigravity-Manager/releases";
    license = lib.licenses.cc-by-nc-sa-40;
    mainProgram = "antigravity-tools";
    platforms = lib.platforms.darwin;
  };
})
