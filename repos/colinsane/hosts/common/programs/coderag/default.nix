# CodeRAG MCP server: local semantic + keyword code search for AI agents
# <https://github.com/Neverdecel/CodeRAG>
#
# TODO: make usable via CLI in a way that auto-indexes (like `ck` does).
{ ... }:
{
  sane.programs.coderag = {
    sandbox.whitelistPwd = true;
    # sandbox.net = "clearnet";  # unless CODERAG_CACHE_DIR contains downloaded models, they will be DL'd on-demand
    persist.byStore.private = [
      ".cache/coderag"
    ];
    suggestedPrograms = [
      "ripgrep"  # search_files uses this internally, allegedly?
    ];

    sandbox.extraHomePaths = [
      # coderag needs to locate the repo state dir to know where to put its cache dir.
      # like git itself, that means crawling *up* the path -- which isn't necessarily in the
      # sandbox otherwise -- to locate parent .git files. So I kinda have to just add all the common dirs.
      "dev"
      "knowledge"
      "nixos"
      "ref"
    ];
  };
}
