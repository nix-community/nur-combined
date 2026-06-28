# CodeRAG MCP server: local semantic + keyword code search for AI agents
# <https://github.com/Neverdecel/CodeRAG>
{ ... }:
{
  sane.programs.coderag = {
    sandbox.whitelistPwd = true;
    # sandbox.net = "clearnet";  # unless CODERAG_CACHE_DIR contains downloaded models, they will be DL'd on-demand
    persist.byStore.private = [
      # ".cache/coderag"
    ];
    suggestedPrograms = [
      "ripgrep"  # search_files uses this internally, allegedly?
    ];
  };
}
