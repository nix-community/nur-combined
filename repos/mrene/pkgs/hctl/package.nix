{
  lib,
  buildGoModule,
  fetchFromGitHub,
  installShellFiles,
}:

buildGoModule rec {
  pname = "hctl";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "xx4h";
    repo = "hctl";
    # rev = "v${version}";
    rev = "fc9c13f60efb7e6c1af8667b0d527ba68e9ff041"; # pull/63
    hash = "sha256-DAvmbLEyFwZ72KAzO7XM5Q/T3NUu3KCfW78L3Wo3ezo=";
  };

  vendorHash = "sha256-7sTf9wBEinYq722DDVuOSNr+IPyYd4C0NGRAlNUVhIU=";

  ldflags = [
    "-s"
    "-w"
    "-X=github.com/xx4h/hctl/cmd.version=v${version}"
    "-X=github.com/xx4h/hctl/cmd.commit=${src.rev}"
    "-X=github.com/xx4h/hctl/cmd.date=1970-01-01T00:00:00Z"
  ];

  nativeBuildInputs = [installShellFiles];

  postInstall = ''
    installShellCompletion --cmd hctl \
      --bash <($out/bin/hctl completion bash) \
      --fish <($out/bin/hctl completion fish) \
      --zsh <($out/bin/hctl completion zsh)
  '';

  # Media playback tests hit the network
  # > Error getting local IP: dial udp 1.1.1.1:53: connect: network is unreachable
  doCheck = false;

  meta = {
    description = "A tool to control your Home Assistant devices from the command-line";
    homepage = "https://github.com/xx4h/hctl";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ mrene ];
    mainProgram = "hctl";
  };
}
