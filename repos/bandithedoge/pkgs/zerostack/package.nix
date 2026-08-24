{
  withAcp ? true,
  withAdvisor ? true,
  withHooks ? true,
  withMemory ? true,
  withMultimodal ? true,
  withPdf ? true,

  fetchFromGitHub,
  lib,
  nix-update-script,
  rustPlatform,

  mold,
  writableTmpDirAsHomeHook,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "zerostack";
  version = "1.7.2";
  src = fetchFromGitHub {
    owner = "gi-dellav";
    repo = "zerostack";
    rev = "v${finalAttrs.version}";
    hash = "sha256-rBFgrZvSnLxLulJxxPeS/+uVk56ifdgDl6JZ0uqtlp8=";
  };

  cargoHash = "sha256-4sHChlm9dt4vB+zAAWbP7vrUY66nUbRsWSRDg9G4RGo=";
  buildFeatures =
    lib.optional withAcp "acp"
    ++ lib.optional withAdvisor "advisor"
    ++ lib.optional withHooks "hooks"
    ++ lib.optional withMemory "memory"
    ++ lib.optional withMultimodal "multimodal"
    ++ lib.optional withPdf "pdf";

  nativeBuildInputs = [ mold ];

  nativeCheckInputs = [ writableTmpDirAsHomeHook ];

  checkFlags = [
    "--skip=tests::session_tests::detect_git_branch_in_repo_returns_nonempty"
    "--skip=tests::logging_tests::test_build_stderr_filter_default"
    "--skip=tests::provider_tests::anthropic_custom_base_appends_v1_messages"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Minimalistic coding agent written in Rust, optimized for memory footprint and performance";
    homepage = "https://github.com/gi-dellav/zerostack";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.unix;
    mainProgram = "zerostack";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
})
