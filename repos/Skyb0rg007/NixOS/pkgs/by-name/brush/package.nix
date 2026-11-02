{
  lib,
  rustPlatform,
  fetchFromGitHub,
  nix-update-script,
  rustc,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "brush";
  version = "0.4.0-unstable-2026-11-01";
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "reubeno";
    repo = "brush";
    rev = "d978b0f6eb9afa7cd35b1352467e14b580b7ce81";
    hash = "sha256-3+ePWEoNaymow/1kBWrZC7Gd4VA8Ql1DRRYtCtsGvxQ=";
  };

  cargoHash = "sha256-L9ppLx3+KcSsA+PKDO6TTyZDjUAr1kl8ofEcEdE+Pfw=";

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
