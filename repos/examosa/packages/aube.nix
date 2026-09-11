{
  lib,
  rustPlatform,
  fetchFromGitHub,
  cmakeMinimal,
  installShellFiles,
  gitMinimal,
  nodejs-slim,
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
  version = "2.2.9";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "aubepkg";
    repo = "aube";
    tag = "v${finalAttrs.version}";
    hash = "sha256-8FaIVRYDKvtayuYzUMFl2e93Dl4EZTVrvGe6TiZJRQU=";
  };

  cargoHash = "sha256-Wob7D0Ly5ElQbl6jKJKbWM93C6/3NJr6XZRwlmgM8i4=";

  nativeBuildInputs = [
    cmakeMinimal
    installShellFiles
    pkg-config
  ];

  buildInputs = [
    zstd
  ];

  postPatch = ''
    substituteInPlace crates/aube/src/commands/exec.rs \
      --replace-fail '"/bin/echo"' "\"$(type -P echo)\""

    substituteInPlace crates/aube-lockfile/src/io.rs crates/aube/src/commands/version.rs \
      --replace-fail '"git"' '"${lib.getExe gitMinimal}"'

    substituteInPlace crates/aube/tests/e2e.rs \
      --replace-fail '"node ' '"${lib.getExe nodejs-slim} '
  '';

  nativeCheckInputs = [
    cacert
    writableTmpDirAsHomeHook
  ];

  # tests mutate AUBE_DISABLE_TLS_TICKET_CACHE and assume serial execution
  dontUseCargoParallelTests = true;

  checkFlags = [
    # The tagged source archive omits the release-generated popularity
    # corpus, so the resolver intentionally embeds an empty fallback.
    "--skip=commands::add_supply_chain::tests::bundled_corpus_detects_common_package_typo"
    # The assertion is incompatible with the usage parser version selected
    # by this build, although the conflicting flags are still rejected.
    "--skip=cli_spec_tests::add_rejects_deny_build_with_dangerously_allow_all_builds"
    # macOS rejects the deliberately non-UTF-8 storage path before the
    # embedded API can exercise it.
    "--skip=facade_install_preserves_non_utf8_storage_paths"
    # This embedded lifecycle fixture invokes a pnpm script, but the Nix
    # test environment does not provide the expected pnpm executable.
    "--skip=facade_routes_lifecycle_output_to_install_events"
  ];

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
