{
  lib,
  rustPlatform,
  fetchFromGitHub,
  nix-update-script,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "brush";
  version = "0.4.0-unstable-2026-08-21";

  src = fetchFromGitHub {
    owner = "reubeno";
    repo = "brush";
    rev = "3a1de7ad56b7a28da02f4cea5b80669fc9e6b2b2";
    hash = "sha256-mZtSF1LYavLZCoYZTrLpUb3zAuDYvvm6J9gNAR6K7zU=";
  };

  cargoHash = "sha256-9Mwzf/hy0peOvMc4eJGCIwUZqW5nnfBR0O/wdZfJRw4=";

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
