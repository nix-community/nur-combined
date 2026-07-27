{
  withAcp ? true,
  withMemory ? true,

  sources,

  lib,
  rustPlatform,

  mold,
  writableTmpDirAsHomeHook,
}:
rustPlatform.buildRustPackage {
  inherit (sources.zerostack) pname src;
  version = lib.removePrefix "v" sources.zerostack.version;

  cargoLock = sources.zerostack.cargoLock."Cargo.lock";
  buildFeatures = lib.optional withAcp "acp" ++ lib.optional withMemory "memory";

  nativeBuildInputs = [ mold ];

  nativeCheckInputs = [ writableTmpDirAsHomeHook ];

  checkFlags = [
    "--skip=tests::session_tests::detect_git_branch_in_repo_returns_nonempty"
    "--skip=tests::logging_tests::test_build_stderr_filter_default"
  ];

  meta = {
    description = "Minimalistic coding agent written in Rust, optimized for memory footprint and performance";
    homepage = "https://github.com/gi-dellav/zerostack";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.unix;
    mainProgram = "zerostack";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
