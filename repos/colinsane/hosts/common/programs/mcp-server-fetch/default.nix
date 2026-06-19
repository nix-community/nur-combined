# <https://github.com/modelcontextprotocol/servers/tree/main/src/fetch>
# MCP server providing a single `fetch` command;
# fetches a url, rendering it to Markdown by default (unless configured to keep as HTML)
{ ... }:
{
  sane.programs.mcp-server-fetch = {
    sandbox.net = "clearnet";
  };
}
