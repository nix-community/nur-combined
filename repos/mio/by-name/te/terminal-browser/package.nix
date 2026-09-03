{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
  pnpm_10,
  pnpmConfigHook,
  fetchPnpmDeps,
  nodejs,
  makeWrapper,
  electron,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "terminal-browser";
  version = "0.7.6";

  src = fetchFromGitHub {
    owner = "zenbu-labs";
    repo = "terminal-browser";
    rev = "v${finalAttrs.version}";
    hash = "sha256-HcylH0C8pWIeeU28Tb7R/76QlpU8lkdLXCUBYMND2y4=";
  };

  cargoDeps = rustPlatform.fetchCargoVendor {
    src = finalAttrs.src;
    sourceRoot = "${finalAttrs.src.name}/engine";
    hash = "sha256-PFJCbUzOWz6w7Offk3E2Io5ddMg3HFcU6MZdZx2Ud/w=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    pnpm = pnpm_10;
    fetcherVersion = 4;
    hash = "sha256-DZdpUyGHqkNNaGcRWJpXpjNWyXLq6fEeV0efb6uQMB0=";
  };

  nativeBuildInputs = [
    rustPlatform.cargoSetupHook
    rustPlatform.rust.cargo
    rustPlatform.rust.rustc
    pnpm_10
    pnpmConfigHook
    nodejs
    makeWrapper
  ];

  # Avoid fetch-electron.sh
  postPatch = ''
    sed -i '/fetch-electron.sh/d' browser/package.json
  '';

  cargoRoot = "engine";
  ELECTRON_SKIP_BINARY_DOWNLOAD = "1";

  buildPhase = ''
    runHook preBuild

    # build rust native module
    (
      cd engine
      cargo build --release -p pixel-node
    )

    mkdir -p browser/native
    cp engine/target/release/libpixel_node.${
      if stdenv.hostPlatform.isDarwin then "dylib" else "so"
    } browser/native/pixel.node

    # bundle js
    mkdir -p browser/dist cli/dist
    bash scripts/bundle.sh browser/src/main.tsx browser/dist/main.js
    bash scripts/bundle.sh cli/src/main.ts cli/dist/main.js

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/terminal-browser/bin $out/share/terminal-browser/browser $out/share/terminal-browser/cli
    cp -r browser/dist $out/share/terminal-browser/browser/
    cp -r cli/dist $out/share/terminal-browser/cli/
    cp -r browser/native $out/share/terminal-browser/browser/

    # copy fonts
    mkdir -p $out/share/terminal-browser/assets/fonts
    cp assets/fonts/JetBrainsMono-Regular.ttf $out/share/terminal-browser/assets/fonts/

    makeWrapper ${electron}/bin/electron $out/bin/terminal-browser \
      --add-flags "$out/share/terminal-browser/cli/dist/main.js" \
      --set TERMINAL_BROWSER_DIST_ROOT "$out/share/terminal-browser" \
      --set ELECTRON_RUN_AS_NODE "1"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Terminal Browser";
    homepage = "https://github.com/zenbu-labs/terminal-browser";
    license = licenses.mit;
    mainProgram = "terminal-browser";
    platforms = platforms.linux ++ platforms.darwin;
  };
})
