{
  lib,
  fetchFromGitHub,
  buildGoModule,
  go_1_27,
}:
# v0.0.7's go.mod requires go >= 1.27.3; nixpkgs' default `go` is 1.26.10.
(buildGoModule.override { go = go_1_27; }) rec {
  pname = "truenas-mcp";
  version = "0.0.7";

  src = fetchFromGitHub {
    owner = "truenas";
    repo = "truenas-mcp";
    rev = "v${version}";
    hash = "sha256-2gUcvUQFHO3H1GmZsJton86v0NaRuLRsWrEbcs0X5TI=";
  };
  vendorHash = "sha256-L7+NJP3SAL0fNvxH12E8Ak8tf6oKe5zUVHdXXteUIh8=";

  ldflags = [
    "-s"
    "-w"
    "-X main.Version=${version}"
  ];

  meta = with lib; {
    description = "A Model Context Protocol (MCP) server for TrueNAS that enables AI models to interact with the TrueNAS API using natural language queries.";
    homepage = "https://github.com/truenas/truenas-mcp";
    license = licenses.gpl3Only;
    mainProgram = pname;
    platforms = platforms.all;
    sourceProvenance = with sourceTypes; [ fromSource ];
  };
}
