{
  lib,
  stdenv,
  rust-bin,
  makeRustPlatform,
  fetchFromGitHub,
  openssl,
  pkg-config,
  versionCheckHook,
  installShellFiles,
  buildPackages,
  writableTmpDirAsHomeHook,
}:

let
  toolchain = rust-bin.stable.latest.minimal;
  rustPlatform = makeRustPlatform {
    rustc = toolchain;
    cargo = toolchain;
  };
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "moon";
  version = "2.1.1";

  src = fetchFromGitHub {
    owner = "moonrepo";
    repo = "moon";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Gd3h10ZkXCUuXR8iVIqgq4KtUsFG9+IdWBW37OJpzBU=";
  };

  cargoHash = "sha256-xmKnKJtnuHmEx8wKZU9Tq7RZ7v2uiK9rckb+s+Vuw/c=";

  cargoBuildFlags = [
    "--bin"
    "moon"
    "--bin"
    "moonx"
  ];

  env = {
    RUSTFLAGS = "-C strip=symbols";
    OPENSSL_NO_VENDOR = 1;
  };

  buildInputs = [ openssl ];
  nativeBuildInputs = [
    pkg-config
    installShellFiles
    writableTmpDirAsHomeHook
  ];

  postInstall = lib.optionalString (stdenv.hostPlatform.emulatorAvailable buildPackages) (
    let
      emulator = stdenv.hostPlatform.emulator buildPackages;
    in
    ''
      installShellCompletion --cmd moon \
        --bash <(${emulator} $out/bin/moon completions --shell bash) \
        --fish <(${emulator} $out/bin/moon completions --shell fish) \
        --zsh <(${emulator} $out/bin/moon completions --shell zsh)
    ''
  );

  doCheck = false;

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  meta = {
    description = "Task runner and repo management tool for the web ecosystem, written in Rust";
    mainProgram = "moon";
    homepage = "https://github.com/moonrepo/moon";
    changelog = "https://github.com/moonrepo/moon/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ flemzord ];
  };
})
