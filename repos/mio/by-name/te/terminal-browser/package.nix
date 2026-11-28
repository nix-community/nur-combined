{
  lib,
  stdenv,
  fetchFromGitHub,
  pnpm_10,
  pnpmConfigHook,
  fetchPnpmDeps,
  nodejs,
  cargo,
  rustc,
  rustPlatform,
  makeWrapper,
  electron,
  writeShellApplication,
  nix-update-script,
}:

(stdenv.mkDerivation (finalAttrs: {
  pname = "terminal-browser";
  version = "0.16.3";

  src = fetchFromGitHub {
    owner = "zenbu-labs";
    repo = "terminal-browser";
    rev = "v${finalAttrs.version}";
    hash = "sha256-Rqr8JfWv+/631eBDIazrsQlmdPjGgYlA0YK/ju1t+q8=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    pnpm = pnpm_10;
    fetcherVersion = 4;
    hash = "sha256-hrvEZjI515ULFMvqNTpxjUa9a0x0/RwEcWjC2DUYvIw=";
  };

  patches = [ ./skip-nix-scroll-helper.patch ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    cargoRoot = "pixel/engine";
    hash = "sha256-Jk4koQQC6p/XrVj7eSfa1Dayr5/yBkGDhu21x3SnefU=";
  };
  cargoRoot = "pixel/engine";

  nativeBuildInputs = [
    pnpm_10
    pnpmConfigHook
    nodejs
    rustPlatform.cargoSetupHook
    cargo
    rustc
    makeWrapper
  ];

  # Avoid fetch-electron.sh
  postPatch = ''
    sed -i '/fetch-electron.sh/d' browser/package.json
    sed -i 's/"tsc -p tsconfig.json"/"tsc -p tsconfig.json || true"/' pixel/packages/pixel/package.json
  '';

  ELECTRON_SKIP_BINARY_DOWNLOAD = "1";
  PIXEL_BUILD_SCROLL_HELPER = lib.optionalString stdenv.hostPlatform.isDarwin "0";

  buildPhase = ''
    runHook preBuild


    # bundle js
    mkdir -p pixel/packages/pixel/electron && echo "declare module \"electron\";" > pixel/packages/pixel/electron/electron.d.ts
    pnpm --filter @zenbu-labs/pixel build
    pnpm --filter @zenbu-labs/pixel build:native -- --release
    mkdir -p browser/dist cli/dist
    bash scripts/bundle.sh browser/src/main.tsx browser/dist/main.js
    bash scripts/bundle.sh cli/src/main.ts cli/dist/main.js

    runHook postBuild
  '';

  installPhase =
    let
      pixelNativePackage = "${if stdenv.hostPlatform.isDarwin then "darwin" else "linux"}-${
        if stdenv.hostPlatform.isAarch64 then "arm64" else "x64"
      }";
    in
    ''
      runHook preInstall

      mkdir -p $out/share/terminal-browser/bin $out/share/terminal-browser/browser $out/share/terminal-browser/cli
      cp -r browser/dist $out/share/terminal-browser/browser/
      cp -r cli/dist $out/share/terminal-browser/cli/
      mkdir -p $out/share/terminal-browser/browser/node_modules/@zenbu-labs/pixel-native-${pixelNativePackage}
      cp -r pixel/packages/native/${pixelNativePackage}/. \
        $out/share/terminal-browser/browser/node_modules/@zenbu-labs/pixel-native-${pixelNativePackage}/
      printf '%s\n' '${finalAttrs.version}' > $out/share/terminal-browser/VERSION
      printf '%s\n' 'stable' > $out/share/terminal-browser/CHANNEL

      # copy fonts
      mkdir -p $out/share/terminal-browser/assets/fonts
      cp assets/fonts/JetBrainsMono-Regular.ttf $out/share/terminal-browser/assets/fonts/

      makeWrapper ${electron}/bin/electron $out/bin/terminal-browser \
        --add-flags "$out/share/terminal-browser/cli/dist/main.js" \
        --set TERMINAL_BROWSER_DIST_ROOT "$out/share/terminal-browser" \
        --set PIXEL_ELECTRON_APP "${electron}/bin/electron" \
        --set ELECTRON_RUN_AS_NODE "1"

      runHook postInstall
    '';

  passthru.updateScript = writeShellApplication {
    name = "update-terminal-browser";
    text = ''
      export UPDATE_NIX_ATTR_PATH="terminal-browser"
      exec ${
        lib.escapeShellArgs (nix-update-script {
          extraArgs = [
            "--version-regex"
            "^v([0-9.]+)$"
          ];
        })
      } "$@"
    '';
  };

  meta = with lib; {
    description = "Terminal Browser";
    homepage = "https://github.com/zenbu-labs/terminal-browser";
    license = licenses.mit;
    mainProgram = "terminal-browser";
    platforms = platforms.linux ++ platforms.darwin;
  };
})).overrideAttrs
  (
    _:
    lib.optionalAttrs stdenv.hostPlatform.isDarwin {
      __noChroot = true;
    }
  )
