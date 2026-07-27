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

  subPackages = ["cmd/mcptools"];

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "Swiss Army Knife CLI for MCP Servers";
    homepage = "https://github.com/f/mcptools";
    license = lib.licenses.mit;
    maintainers = [];
    mainProgram = "mcptools";
  };
})
