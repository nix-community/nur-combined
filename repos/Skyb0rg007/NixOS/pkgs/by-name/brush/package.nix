{
  lib,
  rustPlatform,
  fetchFromGitHub,
  nix-update-script,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "brush";
  version = "0.4.0-unstable-2026-10-12";
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "reubeno";
    repo = "brush";
    rev = "b30e9d9c463b3a6e0c3a8be8ee1b8c3cfeb733bb";
    hash = "sha256-2dc4oRP13rhcvF76VGyVHnjq2kN1dPXyoixnPAnFYUs=";
  };

  cargoHash = "sha256-Fnj5EacJwO1fNkzLZeA5uroosXkAJjW8ev8QXfod9fA=";

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
