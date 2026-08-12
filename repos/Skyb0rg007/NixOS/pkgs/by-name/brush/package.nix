{
  lib,
  rustPlatform,
  fetchFromGitHub,
  nix-update-script,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "brush";
  version = "0.4.0-unstable-2026-08-10";

  src = fetchFromGitHub {
    owner = "reubeno";
    repo = "brush";
    rev = "ec6fcb2123aca0b206c94f042cb3edb78f1d8713";
    hash = "sha256-vPIIzeCZdwOeMBP2I5F6XMvXn+tSm/OcomPJBt2YN5E=";
  };

  cargoHash = "sha256-zxfQtcGB3NxAo4QIGT4wLjBFt0zcHaT+2a4hnIDsnMs=";

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
