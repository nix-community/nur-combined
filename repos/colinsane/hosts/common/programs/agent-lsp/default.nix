# exposes LSPs over MCP, for agent harnesses like Pi
# <https://github.com/blackwell-systems/agent-lsp>
{ ... }:
{
  sane.programs.agent-lsp = {
    sandbox.whitelistPwd = true;
    # sandbox.net = "clearnet";  #< for `agent-lsp update` subcommand?
  };
}
