{
  lib,
  fetchFromGitHub,
  rustPlatform,
  cargo-tauri,
  nodejs,
  pnpm,
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
  stdenv,
  runCommand,
  cacert,
  libsoup_2_4,
}:

let
  version = "1.1.0-unstable-20250430";

  pnpmLock = stdenv.mkDerivation {
    name = "pnpm-lock.yaml";
    src = fetchFromGitHub {
      owner = "canstralian";
      repo = "ForkU-ChatGPT";
      rev = "aa11e67";
      hash = "sha256-1SD4b+jI6s32+wCksYTin+6IAB+mhqSqJADDH2tDkoY=";
    };
    buildInputs = [
      pnpm
      yq-go
      cacert
    ];
    buildPhase = ''
      export SSL_CERT_FILE=${cacert}/etc/ssl/certs/ca-bundle.crt
      export NPM_CONFIG_ENGINE_STRICT=false

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
    outputHash = "sha256-LPkgo8+/sTOYEzujmKk3SaUFf2GCg+fFQ377OgQksJc=";
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
    fetcherVersion = 4;
    hash = "sha256-hlG7EvnNEKfJz0qwwUadUvr/B1VrogS7opVjTgKOOlI=";
  };

  cargoHash = "sha256-OQDh1FQSFnu9rOIkpfotV2VYK444wvodZ7AIcy8859E=";

  nativeBuildInputs = [
    nodejs
    pnpmConfigHook
    pnpm

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

    for f in $cargoDepsCopy/libappindicator-sys-*/src/lib.rs; do
      if [ -f "$f" ]; then
        substituteInPlace "$f" \
          --replace-fail "libayatana-appindicator3.so.1" "${libayatana-appindicator}/lib/libayatana-appindicator3.so.1" || true
      fi
    done

    # Fix wry webkitgtk 4.1 compatibility by importing SettingsExt where needed
    for f in $(find $cargoDepsCopy -path "*/wry-*/src/webview/webkitgtk/*.rs"); do
      if [ -f "$f" ]; then
        chmod +w "$f"
        echo "use webkit2gtk::SettingsExt;" >> "$f" || true
      fi
    done

    substituteInPlace package.json \
      --replace-fail '"version": "0.0.0"' '"version": "${finalAttrs.version}"' \
      --replace-fail '"engines":' '"_engines":'

    substituteInPlace src-tauri/Cargo.toml \
      --replace-fail 'version = "0.0.0"' 'version = "${finalAttrs.version}"'

    substituteInPlace src-tauri/tauri.conf.json \
      --replace-fail '"beforeDevCommand": "npm run dev:fe"' '"beforeDevCommand": "pnpm run dev:fe"' \
      --replace-fail '"beforeBuildCommand": "npm run build:fe"' '"beforeBuildCommand": "pnpm run build:fe"'
    #  --replace-fail '"version": "1.1.0"' '"version": "${finalAttrs.version}"'

  '';

  doCheck = false;

  buildPhase = ''
    runHook preBuild
    pnpm run build:fe || pnpm run build
    cd src-tauri
    cargo build --release
    cd ..
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    if [ -f "target/$CARGO_BUILD_TARGET/release/chatgpt" ]; then
      cp "target/$CARGO_BUILD_TARGET/release/chatgpt" $out/bin/chat-gpt
    elif [ -f "target/release/chatgpt" ]; then
      cp "target/release/chatgpt" $out/bin/chat-gpt
    elif [ -f "src-tauri/target/$CARGO_BUILD_TARGET/release/chatgpt" ]; then
      cp "src-tauri/target/$CARGO_BUILD_TARGET/release/chatgpt" $out/bin/chat-gpt
    elif [ -f "src-tauri/target/release/chatgpt" ]; then
      cp "src-tauri/target/release/chatgpt" $out/bin/chat-gpt
    else
      echo "Could not find chatgpt binary!"
      exit 1
    fi
    runHook postInstall
  '';

  postInstall = ''
    # __NV_DISABLE_EXPLICIT_SYNC -> https://github.com/tauri-apps/tauri/issues/10702
    wrapProgram $out/bin/chat-gpt \
      --set __NV_DISABLE_EXPLICIT_SYNC 1
  '';

  meta = {
    description = "ChatGPT desktop application (ForkU fork)";
    homepage = "https://github.com/canstralian/ForkU-ChatGPT";
    license = lib.licenses.agpl3Only;
    mainProgram = "chat-gpt";
    platforms = lib.platforms.linux;
  };
})
