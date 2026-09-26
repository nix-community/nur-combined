{
  lib,
  rustPlatform,
  fetchFromGitHub,
  stdenv,
  cacert,
  installShellFiles,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "kache";
  version = "0.26.3";

  src = fetchFromGitHub {
    owner = "kunobi-ninja";
    repo = "kache";
    tag = "v${finalAttrs.version}";
    hash = "sha256-7osbe1nDyJmH99oTUvFiWlSPgPkvhO/OCRgxuw6ijtw=";
  };

  cargoHash = "sha256-Mt078AxY84RX+5Lb6q8zdE8R/Qw+e2sd8gouNYWIdXE=";

  nativeBuildInputs = [ installShellFiles ];

  cargoBuildFlags = [
    "-p"
    "kache"
  ];
  cargoTestFlags = [
    "-p"
    "kache"
    # Match upstream's Nix package, which excludes the integration test suite.
    "--bin"
    "kache"
  ];

  # probe::tests::family_probe_cache_dir_expands_tilde failed under parallel tests
  # in 0.26.3: it reads HOME before locking shared process state, so another test
  # can change HOME between that read and tilde expansion.
  dontUseCargoParallelTests = true;

  # These tests need macOS services or nested sandboxes unavailable to Nix builds.
  checkFlags = lib.optionals stdenv.hostPlatform.isDarwin [
    "--skip=store::tests::test_exclude_from_indexing_sets_tmutil_xattr"
    "--skip=fallback::macos::tests::policy_distinguishes_denied_and_allowed_output"
    "--skip=sandbox_preflight_bypasses_denied_server_but_keeps_allowed_server"
  ];
  __darwinAllowLocalNetworking = true;

  preCheck = ''
    ulimit -n 4096 2>/dev/null || true
  '';

  env = {
    RUSTC_WRAPPER = "";
    # HTTP client construction in the tests requires a certificate bundle.
    SSL_CERT_FILE = "${cacert}/etc/ssl/certs/ca-bundle.crt";
  };

  postInstall = ''
    mkdir -p $out/lib/kache
    for name in cc c++ gcc g++ clang clang++; do
      ln -s $out/bin/kache $out/lib/kache/$name
    done
    ln -s lib/kache $out/shims
  ''
  + lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd kache \
      --bash <($out/bin/kache completions bash) \
      --fish <($out/bin/kache completions fish) \
      --zsh <($out/bin/kache completions zsh)
  '';

  meta = {
    description = "Content-addressed build cache for Rust, C/C++ and CUDA";
    homepage = "https://github.com/kunobi-ninja/kache";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ merrkry ];
    mainProgram = "kache";
    platforms = lib.platforms.unix;
  };
})
