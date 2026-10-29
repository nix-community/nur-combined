{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "ampel";
  version = "1.4.1";
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "policylabs";
    repo = "ampel";
    tag = "v${finalAttrs.version}";
    hash = "sha256-LMk3pYAbGvisJoTOkPKUofbpP84H4uE0WsKI5tBbaC8=";
  };

  vendorHash = "sha256-n1AQKR9xHNNYIUCG4fnbarCvvBHc+oujk55+6wSxG6Q=";

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

  meta = {
    description = "Lightweight supply chain policy engine";
    homepage = "https://github.com/policylabs/ampel";
    changelog = "https://github.com/policylabs/ampel/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.skyesoss ];
    mainProgram = "ampel";
  };
})
