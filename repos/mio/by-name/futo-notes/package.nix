{
  lib,
  stdenv,
  fetchFromGitLab,
  rustPlatform,
  cargo-tauri,
  nodejs_22,
  pnpm_9,
  pkg-config,
  wrapGAppsHook3,
  glib,
  gtk3,
  webkitgtk_4_1,
  openssl,
  onnxruntime,
}:

rustPlatform.buildRustPackage rec {
  pname = "futo-notes";
  version = "1.5.5";

  src = fetchFromGitLab {
    domain = "gitlab.futo.org";
    owner = "futo-notes";
    repo = "futo-notes";
    rev = "v${version}";
    hash = "sha256-G6PVrYtjVtjbhEGjz8XqX0UXTLIBoZ8BfDk2x7UpluA=";
  };

  pnpmDeps = pnpm_9.fetchDeps {
    inherit pname version src;
    hash = "sha256-5igR4ZjUUORQastytdojRlrCs64GabkS+cfuuYAvdW8=";
    fetcherVersion = 4;
  };

  cargoHash = "sha256-1wh7kCysh6lDRimLq101v6WwHwsK6GzcboEGMWrQ/ec=";

  # The Cargo workspace root is in the repo root
  # We just want to build the tauri app
  buildAndTestSubdir = "apps/tauri/src-tauri";

  nativeBuildInputs = [
    pkg-config
    cargo-tauri.hook
    nodejs_22
    pnpm_9.configHook
    wrapGAppsHook3
  ];

  buildInputs = [
    glib
    gtk3
    webkitgtk_4_1
    openssl
    onnxruntime
  ];

  preBuild = ''
    pnpm install --offline --frozen-lockfile --ignore-scripts
    # Tauri's hook will run pnpm build if configured in tauri.conf.json,
    # or we can run it manually. Let's run it manually just in case:
    pnpm run build || true
    mkdir -p apps/tauri/src-tauri/gen/linux
    cp ${onnxruntime}/lib/libonnxruntime.so apps/tauri/src-tauri/gen/linux/
  '';

  meta = {
    description = "FUTO Notes";
    homepage = "https://gitlab.futo.org/futo-notes/futo-notes";
    license = lib.licenses.unfree; # Change me
    mainProgram = "futo-notes";
  };
}
