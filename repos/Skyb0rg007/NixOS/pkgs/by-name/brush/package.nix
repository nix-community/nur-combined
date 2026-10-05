{
  lib,
  rustPlatform,
  fetchFromGitHub,
  nix-update-script,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "brush";
  version = "0.4.0-unstable-2026-10-05";

  src = fetchFromGitHub {
    owner = "reubeno";
    repo = "brush";
    rev = "458f805847b9aafb434b44b72b70e5af0a33d64f";
    hash = "sha256-OM2Q7Zi1k87BYpBmOVyQhAh+s4KtQdm3Vfx3VzZrmC4=";
  };

  cargoHash = "sha256-ZnPZam7BnZ0iZV7rC1KFPL+EZXnfoek69+X4X9vZyV8=";

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
