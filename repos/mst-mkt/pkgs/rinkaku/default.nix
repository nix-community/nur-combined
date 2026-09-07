{
  lib,
  rustPlatform,
  fetchFromGitHub,
  git,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "rinkaku";
  version = "0.6.26";

  src = fetchFromGitHub {
    owner = "hiro-o918";
    repo = "rinkaku";
    tag = "v${finalAttrs.version}";
    hash = "sha256-pqrpdf16lRcm5GIuVUAU8Yi2uHKafXp1kz/xsuncc/I=";
  };

  cargoHash = "sha256-1CbtMB4APe9FXZWQXbfLdbrFgEOTJUE4byma5og4Jb4=";

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
