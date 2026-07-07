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
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "aube";
  version = "1.26.0";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "endevco";
    repo = "aube";
    tag = "v${finalAttrs.version}";
    hash = "sha256-bQDDLgO5dG9kMF9VDnHGwuMZjWrbNT5Ia90rJrERDaE=";
  };

  cargoHash = "sha256-L9UiSO9UL8kBOebFXrZqbIJ/V4tobl1NYAdlktmX2lY=";

  nativeBuildInputs = [
    cmakeMinimal
    installShellFiles
    pkg-config
  ];

  buildInputs = [
    zstd
  ];

  postPatch = ''
    substituteInPlace ./crates/aube-lockfile/src/io.rs \
      --replace-fail '"git"' '"${lib.getExe gitMinimal}"'

    substituteInPlace ./crates/aube/src/commands/completion.rs \
      --replace-fail '"usage"' "\"$JDX_USAGE_BIN\""
  '';

  nativeCheckInputs = [
    cacert
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

  meta = {
    broken = lib.versionOlder rustc.version "1.93";
    description = "A fast Node.js package manager";
    homepage = "https://github.com/endevco/aube";
    changelog = "https://github.com/endevco/aube/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = [lib.licenses.mit lib.licenses.bsd2Patent];
    mainProgram = "aube";
  };
})
