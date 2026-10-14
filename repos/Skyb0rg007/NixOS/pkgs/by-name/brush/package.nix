{
  lib,
  rustPlatform,
  fetchFromGitHub,
  nix-update-script,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "brush";
  version = "0.4.0-unstable-2026-10-14";
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "reubeno";
    repo = "brush";
    rev = "facce1118ce76fb496790e62e69422914ebd7ca4";
    hash = "sha256-e3ZVZiWil5tHHIUilB/S1X3By53APyxJgKdXI0fyuS0=";
  };

  cargoHash = "sha256-6HLsbxc3iCDPjcKHphuwxh6gawZBIhZ4SIWnLkP4Fd4=";

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
