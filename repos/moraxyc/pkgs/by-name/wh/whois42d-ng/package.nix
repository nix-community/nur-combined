{
  lib,
  stdenv,
  rustPlatform,
  installShellFiles,
  pkg-config,
  systemd,
  versionCheckHook,

  sources,
  source ? sources.whois42d-ng,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  inherit (source) pname version src;

  cargoDeps = rustPlatform.importCargoLock source.cargoLock."Cargo.lock";

  buildNoDefaultFeatures = true;
  buildFeatures = lib.optionals stdenv.hostPlatform.isLinux [ "systemd" ];

  nativeBuildInputs = [
    installShellFiles
    pkg-config
  ];
  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [ systemd ];

  postInstall =
    lib.optionalString stdenv.hostPlatform.isLinux ''
      substituteInPlace resources/whois42d-ng.service \
        --replace-fail '/usr/local/bin' "$out/bin"
      install -Dm644 resources/whois42d-ng.{service,socket} -t $out/lib/systemd/system
    ''
    + lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
      installShellCompletion --cmd whois42d-ng \
        --zsh <($out/bin/whois42d-ng completions zsh) \
        --bash <($out/bin/whois42d-ng completions bash) \
        --fish <($out/bin/whois42d-ng completions fish)
    '';

  __darwinAllowLocalNetworking = true;

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgramArg = "--version";

  meta = {
    description = "Whois server for the dn42 registry";
    homepage = "https://github.com/moraxyc/whois42d-ng";
    changelog = "https://github.com/Moraxyc/whois42d-ng/blob/master/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ moraxyc ];
    mainProgram = "whois42d-ng";
  };
})
