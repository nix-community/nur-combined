{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
  versionCheckHook,
  nix-update-script,
}:

buildGoModule (finalAttrs: {
  pname = "ampel";
  version = "1.5.0";
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "policylabs";
    repo = "ampel";
    tag = "v${finalAttrs.version}";
    hash = "sha256-YFT3s22yiL3950bS4pxRr8wyToXC0p9VKxDVAZxPM08=";
  };

  vendorHash = "sha256-ZCZOJqSuVIgJVwXtMUH3cuIrbiD7VBJDYx96u2fygf4=";

  excludedPackages = [ "e2e" ];

  ldflags = [
    "-s"
    "-w"
    "-X sigs.k8s.io/release-utils/version.gitVersion=v${finalAttrs.version}"
    "-X sigs.k8s.io/release-utils/version.gitTreeState=clean"
  ];

  nativeBuildInputs = [ installShellFiles ];

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd ampel \
      --bash <($out/bin/ampel completion bash) \
      --fish <($out/bin/ampel completion fish) \
      --zsh <($out/bin/ampel completion zsh)
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgramArg = "version";

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Lightweight supply chain policy engine";
    homepage = "https://github.com/policylabs/ampel";
    changelog = "https://github.com/policylabs/ampel/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.skyesoss ];
    mainProgram = "ampel";
  };
})
