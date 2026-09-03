{
  lib,
  rustPlatform,
  fetchFromGitHub,
  cmakeMinimal,
  installShellFiles,
  gitMinimal,
  cacert,
  pkg-config,
  rustc,
  usage,
  zstd,
  nix-update-script,
  writableTmpDirAsHomeHook,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "aube";
  version = "2.2.4";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "endevco";
    repo = "aube";
    tag = "v${finalAttrs.version}";
    hash = "sha256-kVkvVS3xNW/moeRtHxq+sXMrnYOUVn8evIQgGYR2LHc=";
  };

  cargoHash = "sha256-lIxTy9v3VZNr0sAdpjjWazlqBb0KFdGT4DUDI2mc8Fs=";

  nativeBuildInputs = [
    cmakeMinimal
    installShellFiles
    pkg-config
  ];

  buildInputs = [
    zstd
  ];

  postPatch = ''
    substituteInPlace ./crates/aube-lockfile/src/io.rs ./crates/aube/src/commands/version.rs \
      --replace-fail '"git"' '"${lib.getExe gitMinimal}"'
  '';

  nativeCheckInputs = [
    cacert
    writableTmpDirAsHomeHook
  ];

  # tests mutate AUBE_DISABLE_TLS_TICKET_CACHE and assume serial execution
  dontUseCargoParallelTests = true;

  postInstall = ''
    rm -fv $out/bin/generate-{error-codes,settings}-docs

    completions=()

    for shell in {ba,fi,z}sh; do
      completion=aube.$shell

      $JDX_USAGE_BIN generate completion $shell aube \
        --file aube.usage.kdl > $completion

      completions+=($completion)
    done

    installShellCompletion "''${completions[@]}"

    $JDX_USAGE_BIN generate manpage --file aube.usage.kdl --out-file aube.1
    installManPage aube.1
  '';

  env = {
    JDX_USAGE_BIN = lib.getExe usage;
    ZSTD_SYS_USE_PKG_CONFIG = true;
  };

  passthru.updateScript = nix-update-script {extraArgs = ["--use-github-releases"];};

  meta = {
    broken = lib.versionOlder rustc.version "1.93" || lib.versionOlder usage.version "4";
    description = "A fast Node.js package manager";
    homepage = "https://github.com/endevco/aube";
    changelog = "https://github.com/endevco/aube/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = [lib.licenses.mit lib.licenses.bsd2Patent];
    mainProgram = "aube";
  };
})
