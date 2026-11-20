{
  lib,
  fetchFromGitHub,
  rustPlatform,
  pkg-config,
  sqlite,
  zstd,
  nix-update-script,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cc-switch";
  version = "5.11.4";

  src = fetchFromGitHub {
    owner = "SaladDay";
    repo = "cc-switch-cli";
    rev = "v${finalAttrs.version}";
    hash = "sha256-qrkvHhvKLQVkCfcwsHr/IPPXL9Jp7fFjR6oel65K/Do=";
  };

  cargoRoot = "src-tauri";
  buildAndTestSubdir = finalAttrs.cargoRoot;

  cargoHash = "sha256-2shi1FVCTmVY/9oJuXWj9QX/ATGG9Fs4T1TmNLMgb8o=";

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [
    sqlite
    zstd
  ];

  # Upstream's own flake disables the test suite: it depends on host-specific
  # assistant CLIs and live config fixtures that do not exist in the sandbox.
  doCheck = false;

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "CLI manager for Claude Code, Codex, Gemini, OpenCode and OpenClaw";
    homepage = "https://github.com/SaladDay/cc-switch-cli";
    changelog = "https://github.com/SaladDay/cc-switch-cli/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    mainProgram = "cc-switch";
    platforms = lib.platforms.unix;
  };
})
