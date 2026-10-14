{
  lib,
  rustPlatform,
  fetchFromGitHub,
  stdenv,
  cacert,
  coreutils,
  installShellFiles,
  gitMinimal,
  versionCheckHook,
  writableTmpDirAsHomeHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  __structuredAttrs = true;

  pname = "kache";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "kunobi-ninja";
    repo = "kache";
    tag = "v${finalAttrs.version}";
    hash = "sha256-uefeCZ68g4WyG0UNUVp+vZvdFgxfeOQ1eyuG8XBOHuY=";
  };

  cargoHash = "sha256-fE5Dvf8f1Gv6QB4nuU1abjpJXFRs4ChYUOR5TKLdmM8=";

  strictDeps = true;
  nativeBuildInputs = [ installShellFiles ];
  nativeCheckInputs = [
    gitMinimal
    writableTmpDirAsHomeHook
  ];

  cargoBuildFlags = [
    "-p"
    "kache"
  ];
  # Use upstream's default test profile instead of release LTO for test binaries.
  checkType = "debug";
  cargoTestFlags = [
    "-p"
    "kache"
    "--no-fail-fast"
    # Nested Cargo builds expect target/debug, without Nix's inherited target.
    "--config"
    ''target.${stdenv.hostPlatform.rust.rustcTarget}.runner = "${coreutils}/bin/env -u CARGO_BUILD_TARGET"''
  ];

  preCheck = ''
    # cargo-auditable's workspace wrapper makes kache bypass the fixture builds.
    export PATH="${lib.makeBinPath [ rustPlatform.rust.cargo ]}:$PATH"
    # Keep vendoring available to fixtures, without overriding their rustflags.
    # cargoSetupHook appends the target sections after the source configuration.
    if [[ -f "$NIX_BUILD_TOP/.cargo/config.toml" ]]; then
      sed -i '/^[[:space:]]*\[target\./,$d' "$NIX_BUILD_TOP/.cargo/config.toml"
    fi
    ulimit -n 4096 2>/dev/null || true
  '';

  env = {
    RUSTC_WRAPPER = "";
    KACHE_TEST_SHELL = stdenv.shell;
    # Reuse Cargo's test binary; this build already disables RUSTC_WRAPPER.
    KACHE_TEST_USE_CARGO_BIN_EXE = "1";
    # HTTP client construction in the tests requires a certificate bundle.
    SSL_CERT_FILE = "${cacert}/etc/ssl/certs/ca-bundle.crt";
  };

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    # Let upstream maintain the compiler names and the shim directory marker.
    $out/bin/kache init --shims "$out/lib/kache" --canonical-only
    ln -s lib/kache "$out/shims"

    installShellCompletion --cmd kache \
      --bash <($out/bin/kache completions bash) \
      --fish <($out/bin/kache completions fish) \
      --zsh <($out/bin/kache completions zsh)
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  meta = {
    description = "Zero-copy, content-addressed build cache for Rust, C/C++ and more";
    homepage = "https://github.com/kunobi-ninja/kache";
    changelog = "https://github.com/kunobi-ninja/kache/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ merrkry ];
    mainProgram = "kache";
    platforms = lib.platforms.linux;
  };
})
