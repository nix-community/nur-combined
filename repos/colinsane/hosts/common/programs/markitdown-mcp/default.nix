# <https://github.com/microsoft/markitdown/tree/main/packages/markitdown-mcp>
# > exposes one tool: convert_to_markdown(uri), where uri can be any http:, https:, file:, or data: URI.
{ ... }:
{
  sane.programs.markitdown-mcp = {
    sandbox.net = "clearnet";
  };
}
