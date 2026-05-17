{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "resterm";
  version = "0.39.3";

  src = fetchFromGitHub {
    owner = "unkn0wn-root";
    repo = "resterm";
    rev = "v${version}";
    hash = "sha256-t5A0kFqi2q0z7zBszrGvK54vQpZG948E8byL39UfL68=";
  };

  vendorHash = "sha256-3BSvjt9fprjin5kbDJK1cPkzys1BH8iDEIex9WdDo8s=";

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
