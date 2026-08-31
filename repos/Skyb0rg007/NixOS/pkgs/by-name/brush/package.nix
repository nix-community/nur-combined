{
  lib,
  rustPlatform,
  fetchFromGitHub,
  nix-update-script,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "brush";
  version = "0.4.0-unstable-2026-08-31";

  src = fetchFromGitHub {
    owner = "reubeno";
    repo = "brush";
    rev = "48cbaed5f4412a90fe62c0ceb0826c064ea241ca";
    hash = "sha256-yfUzLjBtmCPPOL68ijwUcvmE3hxUBVYW5Pc8tAJI48U=";
  };

  cargoHash = "sha256-Qg4kLFf13HpR+SzWl/spV3U2vBEwRgGADgj2YhNnBac=";

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
