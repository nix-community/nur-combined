{
  lib,
  fetchFromGitHub,
  rustPlatform,
  stdenv,

  # nativeBuildInputs
  installShellFiles,
  pkg-config,

  # buildInputs
  zstd,

  # nativeInstallCheckInputs
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "aven";
  version = "0.1.49";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "raine";
    repo = "aven";
    tag = "v${finalAttrs.version}";
    hash = "sha256-EV2acTK6aAZ7/oSrB1YT1HY166NGziVtePlVoJ3nc6M=";
  };

  cargoHash = "sha256-yN1Eav8dGmkJ9tPq6BL8ANrZcpZ+06hvOmz9c4JYnHg=";

  nativeBuildInputs = [
    installShellFiles
    pkg-config
  ];

  buildInputs = [ zstd ];

  env = {
    ZSTD_SYS_USE_PKG_CONFIG = 1;
  };

  doCheck = false;

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd aven \
      --bash <($out/bin/aven completions bash) \
      --fish <($out/bin/aven completions fish) \
      --zsh <($out/bin/aven completions zsh)
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  meta = {
    description = "Local-first task manager for power users and agents";
    homepage = "https://aventasks.dev/";
    downloadPage = "https://github.com/raine/aven/releases";
    changelog = "https://github.com/raine/aven/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ prince213 ];
    mainProgram = "aven";
  };
})
