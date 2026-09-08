{
  lib,
  rustPlatform,
  fetchFromGitHub,
  nix-update-script,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "brush";
  version = "0.4.0-unstable-2026-09-07";

  src = fetchFromGitHub {
    owner = "reubeno";
    repo = "brush";
    rev = "02ebe3e4e90db26c687e4cf28bee33f1a4a5341a";
    hash = "sha256-7y3VgC6t6p7Kn98Wkqcz2iz6ko1s/g1DWqCZFILbbmk=";
  };

  cargoHash = "sha256-A5AdSL5Jd9Rdtz7rQVyWSsaoy036IPEJygbsOKnlsA0=";

  postPatch = ''
    rm brush-shell/tests/compat_tests.rs
    sed -i -e '/^\[\[test\]\]$/{N;/name = "brush-compat-tests"/{N;N;N;d}}' brush-shell/Cargo.toml
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version=branch"
      "--version-regex=^brush-v([0-9.]+-unstable-[0-9-]+)$"
    ];
  };

  meta = {
    description = "Bash/POSIX-compatible shell implemented in Rust";
    homepage = "https://github.com/reubeno/brush";
    changelog = "https://github.com/reubeno/brush/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.skyesoss ];
    mainProgram = "brush";
  };
})
