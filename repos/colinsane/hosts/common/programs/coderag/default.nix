# CodeRAG MCP server: local semantic + keyword code search for AI agents
# <https://github.com/Neverdecel/CodeRAG>
#
# TODO: make usable via CLI in a way that auto-indexes (like `ck` does).
# TODO: store embeddings in a XDG dir, not ./.coderag
# - can use `CODERAG_STORE_DIR=/path/to/store` env var, but unclear if that plays nicely with multi-repo usage.
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
