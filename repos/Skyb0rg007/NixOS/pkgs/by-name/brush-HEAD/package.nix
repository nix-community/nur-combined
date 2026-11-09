{
  lib,
  rustPlatform,
  fetchFromGitHub,
  nix-update-script,
  rustc,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "brush";
  version = "0.4.0-unstable-2026-11-09";
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "reubeno";
    repo = "brush";
    rev = "8adb6bc06815c34ccf6503902f6f292e04b1cbba";
    hash = "sha256-wTcf3HTPkvph7hTXzpq4SXDXAiwr8RW3oRYZFlD6gaQ=";
  };

  cargoHash = "sha256-fQAYgQzB2okri3wglygjlp2/8L8izBAXV0WXyzPOFKQ=";

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
    inherit (rustc.meta) platforms;
    hydraPlatforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
})
