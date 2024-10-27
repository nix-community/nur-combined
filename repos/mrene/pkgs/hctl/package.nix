{
  lib,
  buildGoModule,
  fetchFromGitHub,
  installShellFiles,
}:

buildGoModule rec {
  pname = "hctl";
  version = "0.5-unstable-2024-10-27";

  src = fetchFromGitHub {
    owner = "xx4h";
    repo = "hctl";
    # rev = "v${version}";
    rev = "b638f25af04415ace367fe9a95a7e8448201c5db"; # pull/63
    hash = "sha256-U8TLROjJQa3Ogb8oxsfyab7E60LnpWG5vJLqqoom0FY=";
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
