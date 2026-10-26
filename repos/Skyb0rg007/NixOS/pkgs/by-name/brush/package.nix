{
  lib,
  rustPlatform,
  fetchFromGitHub,
  nix-update-script,
  rustc,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "brush";
  version = "0.4.0-unstable-2026-10-24";
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "reubeno";
    repo = "brush";
    rev = "e37b3c91b7f3d2cc5a67cdc38381f480044d7a7b";
    hash = "sha256-mQCRSkkiRCfG6N8BDTI98Ut9NJ6kQfGKWbLnftIL3Gc=";
  };

  cargoHash = "sha256-/3ZgCHB/GwkX/PHQeSKOTBY6KeJjY/pfRXUzPuQ4WaA=";

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
