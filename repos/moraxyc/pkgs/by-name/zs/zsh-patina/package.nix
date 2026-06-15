{
  lib,
  stdenv,
  rustPlatform,
  installShellFiles,
  versionCheckHook,

  sources,
  source ? sources.zsh-patina,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  inherit (source) pname version src;

  cargoDeps = rustPlatform.importCargoLock source.cargoLock."Cargo.lock";

  nativeBuildInputs = [ installShellFiles ];

  postInstall = ''
    install -Dm644 /dev/stdin $out/share/zsh-patina/zsh-patina.plugin.zsh <<EOF
    eval "\$($out/bin/zsh-patina activate)"
    EOF
  ''
  + lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd zsh-patina --zsh <($out/bin/zsh-patina completion)
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgramArg = "--version";

  meta = {
    description = "Blazingly fast Zsh plugin performing syntax highlighting of your command line while you type";
    homepage = "https://github.com/michel-kraemer/zsh-patina";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    maintainers = [ lib.maintainers.moraxyc ];
    mainProgram = "zsh-patina";
  };
})
