{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "resterm";
  version = "1.3.1";

  src = fetchFromGitHub {
    owner = "unkn0wn-root";
    repo = "resterm";
    rev = "v${version}";
    hash = "sha256-V89ix+3Pj78H9rGRdQZ1Gi+e4x73SFkfpfA50diHffk=";
  };

  vendorHash = "sha256-YEiHYCSSPXUJIfejyVwP/E1liy2urGa6iSagCXFGlLM=";

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "Terminal API client for HTTP/GraphQL/gRPC with support for SSH tunnels, WebSockets, SSE, workflows, profiling, OpenAPI and response diffs";
    homepage = "https://github.com/unkn0wn-root/resterm";
    changelog = "https://github.com/unkn0wn-root/resterm/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "resterm";
  };
}
