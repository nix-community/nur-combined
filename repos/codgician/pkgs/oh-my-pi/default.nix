{
  lib,
  stdenvNoCC,
  stdenv,
  bun,
  fetchFromGitHub,
  fetchurl,
  gnutar,
  gzip,
  rustPlatform,
  makeWrapper,
  nodejs,
  versionCheckHook,
  writableTmpDirAsHomeHook,
  git,
  gh,
  xdg-utils,
}:

let
  bunBaseline = bun.overrideAttrs {
    src = fetchurl {
      url = "https://github.com/oven-sh/bun/releases/download/bun-v${bun.version}/bun-linux-x64-baseline.zip";
      hash = "sha256-nYokKSpwaAkCBdqsCloiP19pc29Sh+N7+I07QDHtx1A=";
    };
  };
  src = fetchFromGitHub {
    owner = "can1357";
    repo = "oh-my-pi";
    rev = "v16.4.6";
    hash = "sha256-yvOA1kGGMNIiPmLxyHUik2KFSm8/JwSCXpAJDIb8kqA=";
  };

  bunDeps = stdenvNoCC.mkDerivation {
    pname = "oh-my-pi-bun-deps";
    version = "16.4.6";
    inherit src;

    nativeBuildInputs = [ bunBaseline ];

    outputHashMode = "recursive";
    outputHash = "sha256-qxhLaEqWTbuFGh4neoqxE3BAE9q3HE42SeiWUTd4iEc=";

    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      export HOME="$TMPDIR/home"
      export BUN_INSTALL_CACHE_DIR="$TMPDIR/bun-cache"
      export BUN_TMPDIR="$TMPDIR/bun-tmp"
      mkdir -p "$HOME" "$BUN_INSTALL_CACHE_DIR" "$BUN_TMPDIR" "$out"

      bun install --frozen-lockfile --ignore-scripts

      cp -a . "$out/source"
      rm -rf "$out/source/node_modules/.cache" "$out/source/.cache"
    '';

    dontFixup = true;
  };

in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "oh-my-pi";
  version = "16.4.6";

  src = "${bunDeps}/source";

  cargoHash = "sha256-YpZI4R9bYX87UCHVszqOXLLJ0uhnlhe5QYGrALy3cRc=";

  dontConfigure = true;
  doCheck = false;
  dontPatchELF = true;
  dontStrip = true;

  nativeBuildInputs = [
    bunBaseline
    gnutar
    gzip
    makeWrapper
    nodejs
  ];

  disallowedRequisites = [
    bunBaseline
    bunDeps
    nodejs
  ];

  postPatch = ''
    substituteInPlace packages/coding-agent/src/cli.ts \
      --replace-fail 'if (Bun.semver.order(Bun.version, MIN_BUN_VERSION) < 0) {' 'if (false) {'
    makeWrapper ${nodejs}/bin/node packages/natives/node_modules/.bin/napi \
      --add-flags "$PWD/node_modules/@napi-rs/cli/dist/cli.js"
    substituteInPlace packages/stats/scripts/generate-client-bundle.ts \
      --replace-fail 'await Bun.Archive.write(tempArchivePath, entries, { compress: "gzip" });' 'const archiveProcess = Bun.spawn(
        [
          "sh",
          "-c",
          "tar --sort=name --mtime=@\"$SOURCE_DATE_EPOCH\" --owner=0 --group=0 --numeric-owner -cf - . | gzip -n > \"$1\"",
          "sh",
          tempArchivePath,
        ],
        { cwd: dir },
      );
      if ((await archiveProcess.exited) !== 0) throw new Error("Failed to create stats archive");'
    substituteInPlace packages/natives/scripts/embed-native.ts \
      --replace-fail 'await Bun.write(archivePath, await new Bun.Archive(archiveEntries, { compress: "gzip", level: 9 }).bytes());' 'const archiveProcess = Bun.spawn(
        [
          "sh",
          "-c",
          "archive_path=$1; shift; tar --sort=name --mtime=@\"$SOURCE_DATE_EPOCH\" --owner=0 --group=0 --numeric-owner -cf - \"$@\" | gzip -n > \"$archive_path\"",
          "sh",
          archivePath,
          ...available.map(addon => addon.filename),
        ],
        { cwd: nativeDir },
      );
      if ((await archiveProcess.exited) !== 0) throw new Error("Failed to create native archive");'
  '';

  buildPhase = ''
    runHook preBuild

    export CI=1
    export SOURCE_DATE_EPOCH=1
    # `crates/pi-natives/src/lib.rs` enables the nightly-only
    # `#![feature(alloc_error_hook)]`; permit that exact upstream feature with
    # nixpkgs' stable compiler.
    export RUSTC_BOOTSTRAP=1
    # Upstream otherwise probes the host for AVX2 and can build the modern
    # variant. Pin its documented x64 variant selector to the portable baseline
    # (`x86-64-v2`) so native addon output is reproducible across builders.
    export TARGET_VARIANT=baseline
    bun --cwd=packages/natives run build
    bun packages/coding-agent/scripts/build-binary.ts

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 packages/coding-agent/dist/omp $out/libexec/omp

    makeWrapper $out/libexec/omp $out/bin/omp \
      --suffix PATH : ${
        lib.makeBinPath (
          [
            git
            gh
          ]
          ++ lib.optionals stdenv.hostPlatform.isLinux [ xdg-utils ]
        )
      }

    runHook postInstall
  '';

  nativeInstallCheckInputs = [
    versionCheckHook
    writableTmpDirAsHomeHook
  ];
  doInstallCheck = true;
  versionCheckKeepEnvironment = [ "HOME" ];
  versionCheckProgramArg = "--version";
  postInstallCheck = ''
    $out/bin/omp --smoke-test
  '';

  passthru = {
    inherit bunDeps src;
    updateScript = ./update.sh;
  };

  meta = {
    description = "AI coding agent for the terminal with hash-anchored edits, LSP, DAP, Python, browser, and subagents";
    homepage = "https://github.com/can1357/oh-my-pi";
    changelog = "https://github.com/can1357/oh-my-pi/blob/v${finalAttrs.version}/packages/coding-agent/CHANGELOG.md";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [
      fromSource
      binaryNativeCode
    ];
    platforms = [ "x86_64-linux" ];
    maintainers = with lib.maintainers; [ codgician ];
    mainProgram = "omp";
  };
})
