{
  lib,
  fetchFromGitHub,
  rustPlatform,
  cargo-tauri_1,
  nodejs,
  pnpm_9,
  fetchPnpmDeps,
  pnpmConfigHook,
  pkg-config,
  glib-networking,
  openssl,
  webkitgtk_4_1,
  wrapGAppsHook4,
  libsoup_3,
  libayatana-appindicator,
  yq-go,
  writeShellScriptBin,
  stdenv,
  runCommand,
  cacert,
  libsoup_2_4,
}:

let
  version = "1.1.0-unstable-20250430";

  pnpmWrapper =
    (writeShellScriptBin "pnpm" ''
      export NPM_CONFIG_ENGINE_STRICT=false
      export NPM_CONFIG_FROZEN_LOCKFILE=false
      exec ${pnpm_9}/bin/pnpm "$@"
    '').overrideAttrs
      (old: {
        version = pnpm_9.version;
      });

  pnpmLock = stdenv.mkDerivation {
    name = "pnpm-lock.yaml";
    src = fetchFromGitHub {
      owner = "canstralian";
      repo = "ForkU-ChatGPT";
      rev = "c828fa01c04c885f75780e89a0a10082979b10b5";
      hash = "sha256-drJnKup0oWEdFeC3W8iYjZbzEIEI+G4si0/StVwFfGU=";
    };
    buildInputs = [
      pnpmWrapper
      yq-go
      cacert
    ];
    buildPhase = ''
      export SSL_CERT_FILE=${cacert}/etc/ssl/certs/ca-bundle.crt

      # Patch package.json
      substituteInPlace package.json \
        --replace-fail '"version": "0.0.0"' '"version": "${version}"' \
        --replace-fail '"engines":' '"_engines":'

      # Regenerate lockfile
      pnpm install --lockfile-only --ignore-scripts --no-frozen-lockfile
    '';
    installPhase = "cp pnpm-lock.yaml $out";
    outputHashMode = "flat";
    outputHashAlgo = "sha256";
    outputHash = "sha256-BKFtW/HzEpo4xl7W4MyDyBJ2mlknx0o8DlfAW/CvTMM=";
  };

  # Patched source for dependencies fetching
  pnpmDepsSrc = runCommand "pnpm-deps-src" { } ''
    cp -r ${pnpmLock.src} $out
    chmod -R +w $out
    cp ${pnpmLock} $out/pnpm-lock.yaml
  '';
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "forku-chatgpt";
  inherit version;

  src = pnpmLock.src;

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version;
    src = pnpmDepsSrc;
    pnpm = pnpmWrapper;
    fetcherVersion = 1;
    hash = "sha256-QMRT44RR8Y3yz7Rq9UCqi7KKjG8CC4dFhuJJ1JX/2u4=";
  };

  cargoHash = "sha256-OQDh1FQSFnu9rOIkpfotV2VYK444wvodZ7AIcy8859E=";

  nativeBuildInputs = [
    cargo-tauri_1.hook
    nodejs
    pnpmConfigHook
    pnpmWrapper

    pkg-config
    wrapGAppsHook4
    yq-go
  ];

  buildInputs = [
    libayatana-appindicator
    glib-networking
    openssl
    webkitgtk_4_1
    libsoup_3
  ];

  preConfigure = ''
    # Alias pkg-config files to satisfy legacy requirements
    mkdir -p pkgconfig-hack
    export PKG_CONFIG_PATH=$PWD/pkgconfig-hack:$PKG_CONFIG_PATH

    # Helper to alias pc files using pkg-config lookup
    alias_pc() {
      src=$1
      dst=$2
      # We need to find the directory containing the src pc file
      # pkg-config --variable=pcfiledir might not work if it hasn't loaded it yet?
      # Actually it works if it's in the path.
      pcdir=$(pkg-config --variable=pcfiledir "$src")
      ln -s "$pcdir/$src.pc" "pkgconfig-hack/$dst.pc"
    }

    alias_pc javascriptcoregtk-4.1 javascriptcoregtk-4.0
    alias_pc webkit2gtk-4.1 webkit2gtk-4.0
    alias_pc libsoup-3.0 libsoup-2.4
    alias_pc ayatana-appindicator3-0.1 appindicator3-0.1

    # Alias libraries for linker
    mkdir -p lib-hack
    ln -s ${webkitgtk_4_1}/lib/libwebkit2gtk-4.1.so lib-hack/libwebkit2gtk-4.0.so
    ln -s ${webkitgtk_4_1}/lib/libjavascriptcoregtk-4.1.so lib-hack/libjavascriptcoregtk-4.0.so
    ln -s ${libsoup_3}/lib/libsoup-3.0.so lib-hack/libsoup-2.4.so

    export NIX_LDFLAGS="-L$PWD/lib-hack $NIX_LDFLAGS"
  '';

  postPatch = ''
    # Use the generated lockfile
    cp ${pnpmLock} pnpm-lock.yaml

    substituteInPlace $cargoDepsCopy/libappindicator-sys-*/src/lib.rs \
      --replace-fail "libayatana-appindicator3.so.1" "${libayatana-appindicator}/lib/libayatana-appindicator3.so.1"

    substituteInPlace package.json \
      --replace-fail '"version": "0.0.0"' '"version": "${finalAttrs.version}"' \
      --replace-fail '"engines":' '"_engines":'

    substituteInPlace src-tauri/Cargo.toml \
      --replace-fail 'version = "0.0.0"' 'version = "${finalAttrs.version}"'

    substituteInPlace src-tauri/tauri.conf.json \
      --replace-fail '"beforeDevCommand": "npm run dev:fe"' '"beforeDevCommand": "pnpm run dev:fe"' \
      --replace-fail '"beforeBuildCommand": "npm run build:fe"' '"beforeBuildCommand": "pnpm run build:fe"' \
      --replace-fail '"version": "1.1.0"' '"version": "${finalAttrs.version}"'

  '';

  doCheck = false;

  meta = {
    description = "ChatGPT desktop application (ForkU fork)";
    homepage = "https://github.com/canstralian/ForkU-ChatGPT";
    license = lib.licenses.agpl3Only;
    mainProgram = "chat-gpt";
    platforms = lib.platforms.linux;
  };
})
