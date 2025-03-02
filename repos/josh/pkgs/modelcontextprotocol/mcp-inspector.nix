{ nur, runCommand }:
nur.repos.josh.nodePackages."@modelcontextprotocol/inspector".overrideAttrs (
  finalAttrs: _previousAttrs: {
    pname = "mcp-inspector";
    name = "mcp-inspector-${finalAttrs.version}";

    meta.mainProgram = "mcp-inspector";
  }
)
