{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "resterm";
  version = "1.18.0";

  src = fetchFromGitHub {
    owner = "unkn0wn-root";
    repo = "resterm";
    rev = "v${version}";
    hash = "sha256-INZAqyQXRYbc0O0+k6M1XHbiiEHK3Nn21+ONHSW6keA=";
  };

  vendorHash = "sha256-nFQEVLXeltpz6CDEpZ71uKKs+yrM+fphaX13N4qULAU=";

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
