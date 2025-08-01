{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule (finalAttrs: {
  pname = "mcptools";
  version = "0.7.1";

  src = fetchFromGitHub {
    owner = "f";
    repo = "mcptools";
    rev = "v${finalAttrs.version}";
    hash = "sha256-UFK57MzsxoLdtdFhhQ+x57LomyOBijxyHkOCgj6NuJI=";
  };

  vendorHash = "sha256-tHMBwYZUrcohUEpIXgbhSCkxRi+/GxnPtEX4Uj5rwjo=";

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "Command-line interface for interacting with MCP (Model Context Protocol) servers using both stdio and HTTP transport";
    homepage = "https://github.com/f/mcptools";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nagy ];
    mainProgram = "mcptools";
  };
})
