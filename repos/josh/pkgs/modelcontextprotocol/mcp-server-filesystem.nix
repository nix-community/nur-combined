{ nur, runCommand }:
nur.repos.josh.nodePackages."@modelcontextprotocol/server-filesystem".overrideAttrs (
  finalAttrs: _previousAttrs: {
    pname = "mcp-server-filesystem";
    name = "mcp-server-filesystem-${finalAttrs.version}";

    meta.mainProgram = "mcp-server-filesystem";
  }
)
