{
  lib,
  rustPlatform,
  fetchFromGitHub,
  nix-update-script,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "brush";
  version = "0.4.0-unstable-2026-09-17";

  src = fetchFromGitHub {
    owner = "reubeno";
    repo = "brush";
    rev = "e21a63926dbb7301bcc0341d5f45252ef80143e4";
    hash = "sha256-9x+3VLJ8Fqcx3LrZgov2xL62noVpZdolaRM6MuROiK4=";
  };

  cargoHash = "sha256-28rJZ87vUH6mn0Qz6nadTp2RfHvirNFd5N65Na8/8yA=";

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
