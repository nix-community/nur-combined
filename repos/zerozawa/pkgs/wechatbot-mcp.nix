{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage rec {
  pname = "wechatbot-mcp";
  version = "0-unstable-5690c6c";

  src = fetchFromGitHub {
    owner = "zhyyyq";
    repo = "wechatbot-mcp";
    rev = "5690c6c268410b2aa218d6501d12f99ca98b63a3";
    hash = "sha256-wOnYLxFINxHdRIXTLrQk0wJ3apQe+l1PXS+3RUI0hSE=";
  };

  npmDepsHash = "sha256-t+M/0LGPx/VqZamoc6jcyXSzZKGtI18RvidvKxyeMcg=";

  npmBuildScript = "build";

  # tsc emits no shebang; bin entry is dist/index.js
  postInstall = ''
    sed -i '1i #!/usr/bin/env node' $out/lib/node_modules/wechatbot-mcp/dist/index.js
  '';

  meta = with lib; {
    description = "OpenCode / MCP server wrapping @wechatbot/wechatbot — the official WeChat iLink Bot SDK (Tencent partner program, not a hook / reverse-engineered client).";
    homepage = "https://github.com/zhyyyq/wechatbot-mcp";
    license = licenses.mit;
    platforms = platforms.linux;
    mainProgram = "wechatbot-mcp";
    sourceProvenance = with sourceTypes; [ fromSource ];
  };
}
