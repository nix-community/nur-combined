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
  version = "0.1.48";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "raine";
    repo = "aven";
    tag = "v${finalAttrs.version}";
    hash = "sha256-9zmarfhCAQI+Q1tiRRb+CB16uwlQxPfCkmUNPqr1Uwk=";
  };

  cargoHash = "sha256-Q4mfZxSmzXchatzOJpk6VJhcymk5ZPNb4lmt7Icb0m8=";

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
