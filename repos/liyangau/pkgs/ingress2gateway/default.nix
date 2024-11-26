{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "ingress2gateway";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "kubernetes-sigs";
    repo = "ingress2gateway";
    rev = "v${version}";
    hash = "sha256-xAoJREGktbSNGYdrmPuYG2G+xaQ+kReSSA1JBgWaPVY=";
  };

  vendorHash = "sha256-T6I8uYUaubcc1dfDu6PbQ9bDDLqGuLGXWnCZhdvkycE=";

  ldflags = [
    "-s"
    "-w"
  ];

  meta = with lib; {
    description = "Convert Ingress resources to Gateway API resources";
    homepage = "https://github.com/kubernetes-sigs/ingress2gateway";
    changelog = "https://github.com/kubernetes-sigs/ingress2gateway/blob/${src.rev}/CHANGELOG.md";
    license = licenses.asl20;
    mainProgram = "ingress2gateway";
  };
}
