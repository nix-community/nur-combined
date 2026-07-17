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
  version = "0.100.0";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "Edgenesis";
    repo = "shifu";
    tag = "v${finalAttrs.version}";
    hash = "sha256-tNkeQavVUvO4KfSj7rqIqKNQa5Jpybkr2wO2KQYUO98=";
  };

  vendorHash = "sha256-VAOmiAO1dYByrQL1PRUweyKNT/fCfF21/SO1ytlMqDo=";

  nativeBuildInputs = [ installShellFiles ];

  buildInputs = [ libpcap ];

  subPackages = [
    "cmd/deviceshifu/cmdhttp"
    "cmd/deviceshifu/cmdmqtt"
    "cmd/deviceshifu/cmdopcua"
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
    broken = true; # https://github.com/NixOS/nixpkgs/pull/519903
  };
})
