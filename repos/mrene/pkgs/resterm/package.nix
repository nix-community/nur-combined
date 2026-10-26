{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "resterm";
  version = "1.16.1";

  src = fetchFromGitHub {
    owner = "unkn0wn-root";
    repo = "resterm";
    rev = "v${version}";
    hash = "sha256-vzyNJGqZO8eWXPOJemeXttsnuIx/z/GOVfAbu4MR/yI=";
  };

  vendorHash = "sha256-H4V0F8dJEhs6HdHTIMGx0CEv4ZM277lkILXjNFT2oPg=";

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
