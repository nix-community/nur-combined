{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchurl,
  autoPatchelfHook,
  fetchPnpmDeps,
  pnpmConfigHook,
  pnpm_12,
  nodejs_22,
  electron,
  rustPlatform,
  cargo,
  rustc,
  pkg-config,
  dbus,
  makeWrapper,
  nix-update-script,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "eidos-lite";
  version = "0.34.0";

  src = fetchFromGitHub {
    owner = "mayneyao";
    repo = "eidos";
    tag = "lite-v${finalAttrs.version}";
    hash = "sha256-KvS7rIqXfNPAMowuoM7iUvlctHD1Pr5VcGmCqry5OEg=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs)
      pname
      version
      src
      patches
      ;
    pnpm = pnpm_12;
    fetcherVersion = 5;
    hash = "sha256-pRHqLHVF4QdcgulOoeqPb/4cG9NbVTyIzy2o12biVZY=";
  };

  patches = [ ./fix-lockfile.patch ];

  cargoDeps = rustPlatform.importCargoLock {
    # Keep in sync with the source; NUR's restricted eval cannot read fetched files.
    lockFile = ./Cargo.lock;
    outputHashes = {
      "graft-0.16.1" = "sha256-s2p/myqmqh5go6TGevxBTXUFCjqmo9eSfJZSWm3Le68=";
      "opendal-0.55.0" = "sha256-rMwbc1zv4vgpBeJL4dgpYJW3o4rSiCKxr7BWWd5P90U=";
    };
  };

  nativeBuildInputs = [
    nodejs_22
    pnpm_12
    pnpmConfigHook
    makeWrapper
    cargo
    rustc
    rustPlatform.cargoSetupHook
    rustPlatform.bindgenHook
    pkg-config
    autoPatchelfHook
  ];

  buildInputs = [
    dbus
    stdenv.cc.cc.lib
  ];

  env.SQLITE_FS_META_PATH = fetchurl {
    url = "https://github.com/mayneyao/sqlite-fs-meta/releases/download/v0.3.0/libfs_meta-${stdenv.hostPlatform.rust.rustcTarget}.so";
    hash =
      {
        x86_64-linux = "sha256-pJK4nfYRSXb4b7UF3/e6lbvMx1FA55sR10cUBUkAgaE=";
        aarch64-linux = "sha256-VHesMRkjWigMYJ6txaPVNSKpYwh0dWfAul35HpWBnq0=";
      }
      .${stdenv.hostPlatform.system};
  };

  env.ELECTRON_SKIP_BINARY_DOWNLOAD = "1";
  env.CARGO_NET_OFFLINE = "true";

  buildPhase = ''
    runHook preBuild

    export EIDOS_LITE_SPARK_PUBLIC_KEY_PRODUCTION=$(node -p \
      'JSON.parse(require("fs").readFileSync("apps/eidos-lite-desktop/spark-public-keys.json", "utf8")).production')

    pnpm --filter @eidos.space/eidos-file build
    pnpm --filter @eidos.space/eidos-file-ui build
    pnpm --filter @eidos.space/markdown build
    pnpm --filter @eidos.space/eidos-lite-desktop build:production
    pnpm --filter @eidos.space/eidos-lite-desktop prepare:publish-engine
    pnpm --filter @eidos.space/eidos-lite-desktop prepare:vtab
    pnpm --filter @eidos.space/eidos-lite-desktop exec electron-builder --dir --publish never \
      --config electron-builder.json \
      -c.electronDist=${electron}/libexec/electron \
      -c.electronVersion=${electron.version}

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/eidos-lite $out/bin
    cp -r apps/eidos-lite-desktop/dist-app/*-unpacked/resources/* $out/share/eidos-lite/

    makeWrapper ${electron}/bin/electron $out/bin/eidos-lite \
      --add-flags "$out/share/eidos-lite/app.asar"

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "^lite-v(\\d+\\.\\d+\\.\\d+)$"
    ];
  };

  meta = {
    description = "A single-file relational spreadsheet for you and your agent";
    homepage = "https://eidos.space";
    license = lib.licenses.agpl3Only;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
})
