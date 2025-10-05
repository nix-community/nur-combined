{
  lib,
  stdenv,
  buildGoModule,
  fetchFromGitHub,
  installShellFiles,
  libpcap,
}:

buildGoModule (finalAttrs: {
  pname = "shifu";
  version = "0.73.0";

  src = fetchFromGitHub {
    owner = "Edgenesis";
    repo = "shifu";
    tag = "v${finalAttrs.version}";
    hash = "sha256-XKfnBXKdob+mxVVmjro8LUZoxUFYWRemyNfD5fo+FQU=";
  };

  vendorHash = "sha256-YCHEOe1VpmqJhBirmeIU5MyrxRnDOXdahr+gr4EDKXY=";

  nativeBuildInputs = [ installShellFiles ];

  buildInputs = [ libpcap ];

  subPackages = [
    "cmd/deviceshifu/cmdhttp"
    "cmd/deviceshifu/cmdmqtt"
    "cmd/deviceshifu/cmdopcua"
    "cmd/deviceshifu/cmdplc4x"
    "cmd/deviceshifu/cmdsocket"
    "cmd/httpstub/powershellstub"
    "cmd/httpstub/sshstub"
    "cmd/shifuctl"
    "cmd/telemetryservice"
  ];

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd shifuctl \
      --bash <($out/bin/shifuctl completion bash) \
      --fish <($out/bin/shifuctl completion fish) \
      --zsh <($out/bin/shifuctl completion zsh)
  '';

  meta = {
    description = "Kubernetes-native IoT gateway";
    homepage = "https://shifu.dev/";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.sikmir ];
    mainProgram = "shifuctl";
  };
})
