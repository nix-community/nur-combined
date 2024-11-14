{
  lib,
  stdenv,
  buildGoModule,
  fetchFromGitHub,
  installShellFiles,
  libpcap,
}:

buildGoModule rec {
  pname = "shifu";
  version = "0.57.0";

  src = fetchFromGitHub {
    owner = "Edgenesis";
    repo = "shifu";
    rev = "v${version}";
    hash = "sha256-RRK8N/CLNWf9Jkq1Y2wJ2BGgjJNNc2roI9ChREkF06I=";
  };

  vendorHash = "sha256-SCse0FybcWNLshY0stgbV/AC3Y17znFtAKKhtCaZeGM=";

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
}
