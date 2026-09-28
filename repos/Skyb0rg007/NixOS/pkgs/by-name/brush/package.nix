{
  lib,
  rustPlatform,
  fetchFromGitHub,
  nix-update-script,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "brush";
  version = "0.4.0-unstable-2026-09-28";

  src = fetchFromGitHub {
    owner = "reubeno";
    repo = "brush";
    rev = "37efff61920d6bb8fe5155d4431bc597417ba6c7";
    hash = "sha256-0c2mk/ZNKEvNmYQzdsJERq7Y93hlo8wTHfjW4qYTHK0=";
  };

  cargoHash = "sha256-WV5/I3lSAS8tzUcQNxmzT58sq6PtX+oq8jw84MQrPEc=";

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
