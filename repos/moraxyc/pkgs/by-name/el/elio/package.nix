{
  lib,
  stdenv,
  rustPlatform,
  pkg-config,
  installShellFiles,

  zstd,

  versionCheckHook,

  sources,
  source ? sources.elio,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  inherit (source) pname version src;

  cargoDeps = rustPlatform.importCargoLock source.cargoLock."Cargo.lock";

  nativeBuildInputs = [
    pkg-config
    installShellFiles
  ];

  buildInputs = [ zstd ];

  postInstall = ''
    install -Dm644 packaging/linux/elio.desktop -t $out/share/applications
    cp -r packaging/linux/icons $out/share
  ''
  + lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd elio \
      --zsh <($out/bin/elio shell init zsh) \
      --bash <($out/bin/elio shell init bash) \
      --fish <($out/bin/elio shell init fish) \
      --nushell <($out/bin/elio shell init nu)
  '';

  doCheck = false; # tests are flaky

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgramArg = "--version";

  meta = {
    description = "Snappy, batteries-included terminal file manager";
    homepage = "https://github.com/elio-fm/elio";
    changelog = "https://github.com/elio-fm/elio/blob/main/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ moraxyc ];
    mainProgram = "elio";
    platforms = lib.platforms.unix;
  };
})
