{
  lib,
  rustPlatform,
  fetchFromGitHub,
  git,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "rinkaku";
  version = "0.6.22";

  src = fetchFromGitHub {
    owner = "hiro-o918";
    repo = "rinkaku";
    tag = "v${finalAttrs.version}";
    hash = "sha256-NMgIBplLUkFYYBI47d7rebWXcJDaEvo6vxEaqezD/R0=";
  };

  cargoHash = "sha256-vzecreMKsNoG1FiTtEFnVbw5oxT5BVDrWnyZSmiWUQY=";

  # the git/github/pipeline tests spawn real `git` processes in tempdir repos
  nativeCheckInputs = [ git ];

  # expects a debug_assert! to fire, which release builds compile out
  checkFlags = [
    "--skip=source::tests::should_panic_in_debug_builds_when_relative_path_is_actually_absolute"
  ];

  meta = {
    description = "Condense PR diffs into signatures and their dependencies for LLM-friendly review";
    homepage = "https://github.com/hiro-o918/rinkaku";
    changelog = "https://github.com/hiro-o918/rinkaku/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    mainProgram = "rinkaku";
  };
})
