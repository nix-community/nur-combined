{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
  cargo-tauri,
  nodejs,
  pnpm,
  fetchPnpmDeps,
  pnpmConfigHook,
  pkg-config,
  wrapGAppsHook4,
  protobuf,
  webkitgtk_4_1,
  glib-networking,
  openssl,
  libsoup_3,
  cargo,
  cacert,
  runCommand,
  perl,
  fetchurl,
}:

rustPlatform.buildRustPackage rec {
  pname = "dtv";
  version = "3.0.3";

  src = fetchFromGitHub {
    owner = "chen-zeong";
    repo = "DTV";
    rev = "v${version}";
    sha256 = "0n3bmr3phpbnzib71llxgcw75b4vkliq9h7nidzpz19p0s9k3wgl";
  };

  pnpmLock = stdenv.mkDerivation {
    name = "pnpm-lock.yaml";
    inherit src;
    nativeBuildInputs = [
      pnpm
      cacert
    ];

    buildPhase = ''
      sed -i 's/"@tauri-apps\/api": "\^2.7.0"/"@tauri-apps\/api": "^2.11.0"/' package.json
      sed -i 's/"@tauri-apps\/plugin-opener": "\^2.4.0"/"@tauri-apps\/plugin-opener": "^2.5.4"/' package.json
      sed -i 's/"@tauri-apps\/api": "\^2.7.0"/"@tauri-apps\/api": "^2.11.0"/' web/package.json
      sed -i 's/"@tauri-apps\/plugin-opener": "\^2.4.0"/"@tauri-apps\/plugin-opener": "^2.5.4"/' web/package.json
      export SSL_CERT_FILE=${cacert}/etc/ssl/certs/ca-bundle.crt
      export NPM_CONFIG_ENGINE_STRICT=false
      pnpm install --lockfile-only --ignore-scripts --no-frozen-lockfile
    '';
    installPhase = "cp pnpm-lock.yaml $out";
    outputHashMode = "flat";
    outputHashAlgo = "sha256";
    outputHash = "sha256-pe0RXAuhPSGy1MyY658vyvlL1QZdRoAQMHmOXvBPb9s=";
  };

  pnpmDepsSrc = runCommand "pnpm-deps-src" { } ''
    cp -r ${src} $out
    chmod -R +w $out
    sed -i 's/"@tauri-apps\/api": "\^2.7.0"/"@tauri-apps\/api": "^2.11.0"/' $out/package.json
    sed -i 's/"@tauri-apps\/plugin-opener": "\^2.4.0"/"@tauri-apps\/plugin-opener": "^2.5.4"/' $out/package.json
    sed -i 's/"@tauri-apps\/api": "\^2.7.0"/"@tauri-apps\/api": "^2.11.0"/' $out/web/package.json
    sed -i 's/"@tauri-apps\/plugin-opener": "\^2.4.0"/"@tauri-apps\/plugin-opener": "^2.5.4"/' $out/web/package.json
    cp ${pnpmLock} $out/pnpm-lock.yaml
  '';

  pnpmDeps = fetchPnpmDeps {
    inherit pname version;
    src = pnpmDepsSrc;
    fetcherVersion = 3;
    hash = "sha256-guqcYV9cAWQQy/BBYbSJRzTRORhMM5ggPMEq/3Id6MA=";
  };

  buildAndTestSubdir = "src-tauri";

  cargoDeps = stdenv.mkDerivation {
    name = "dtv-vendor";
    inherit src;
    nativeBuildInputs = [

      cargo
      cacert
    ];
    buildPhase = ''
      export CARGO_HOME=$(mktemp -d)
      export SSL_CERT_FILE=${cacert}/etc/ssl/certs/ca-bundle.crt
      export CARGO_HTTP_USER_AGENT="nixpkgs"
      cd src-tauri
      cp ${./Cargo.lock} Cargo.lock
      cargo vendor $out
      cp Cargo.lock $out/Cargo.lock
      substituteInPlace $out/tars-stream/src/lib.rs --replace-warn "#![feature(try_from)]" "" || true
      sed -i 's/"files":{[^}]*}/"files":{}/' $out/tars-stream/.cargo-checksum.json
    '';
    dontFixup = true;
    dontInstall = true;
    outputHashMode = "recursive";
    outputHashAlgo = "sha256";
    outputHash = "sha256-hHt76rnn+Ip+q1UOUAY2GdgU6fVtBwfj7H2kH04g8Zk=";
  };

  nativeBuildInputs = [
    cargo-tauri.hook
    nodejs
    pnpmConfigHook
    pnpm
    pkg-config
    wrapGAppsHook4
    protobuf
    perl
  ];

  buildInputs = [
    openssl
    webkitgtk_4_1
    libsoup_3
    glib-networking
  ];

  postPatch = ''
    sed -i 's/"@tauri-apps\/api": "\^2.7.0"/"@tauri-apps\/api": "^2.11.0"/' package.json
    sed -i 's/"@tauri-apps\/plugin-opener": "\^2.4.0"/"@tauri-apps\/plugin-opener": "^2.5.4"/' package.json
    sed -i 's/"@tauri-apps\/api": "\^2.7.0"/"@tauri-apps\/api": "^2.11.0"/' web/package.json
    sed -i 's/"@tauri-apps\/plugin-opener": "\^2.4.0"/"@tauri-apps\/plugin-opener": "^2.5.4"/' web/package.json
    cp ${pnpmLock} pnpm-lock.yaml
    cp ${./Cargo.lock} Cargo.lock
    cp ${./Cargo.lock} src-tauri/Cargo.lock
  '';

  rustyV8 = fetchurl (
    let
      urls = {
        "x86_64-linux" = {
          url = "https://github.com/denoland/rusty_v8/releases/download/v0.93.1/librusty_v8_release_x86_64-unknown-linux-gnu.a.gz";
          hash = "sha256-ttbwIxzMgihfwwjh3usu7FxVTwLt7ceXU+MyaxXfkxk=";
        };
        "aarch64-linux" = {
          url = "https://github.com/denoland/rusty_v8/releases/download/v0.93.1/librusty_v8_release_aarch64-unknown-linux-gnu.a.gz";
          hash = "sha256-4g8E2F2pQcT/aE+lOQJ+01w/E6R8fG52vD6a1x8iZg4=";
        };
      };
    in
    urls.${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}")
  );

  preBuild = ''
    export RUSTY_V8_ARCHIVE=${rustyV8}
    export RUSTC_BOOTSTRAP=1
  '';

  meta = {
    description = "DTV";
    homepage = "https://github.com/chen-zeong/DTV";
    license = lib.licenses.mit;
    mainProgram = "dtv";
    platforms = lib.platforms.linux;
  };
}
