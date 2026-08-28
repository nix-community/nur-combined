{ lib
, buildNpmPackage
, fetchFromGitHub
, nodejs
}:

buildNpmPackage rec {
  pname = "bln-mcp-server";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "theluckystrike";
    repo = "bln-mcp-grammar-server";
    rev = "v${version}";
    hash = "sha256-FkFDtNPIUohvvSYJV3Pa79IIPbWac1SKWBR72NDIukU=";
  };

  npmDepsHash = "sha256-G1Qt7o2XV03Xds8vm+/2sklTXKE9HLZeHvCKejOg/fM=";

  inherit nodejs;

  # Plain ESM sources; there is no build step.
  dontNpmBuild = true;

  # Smoke test: drive the stdio transport and assert the four tools are listed.
  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    printf '%s\n' \
      '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"installCheck","version":"1"}}}' \
      '{"jsonrpc":"2.0","method":"notifications/initialized"}' \
      '{"jsonrpc":"2.0","id":2,"method":"tools/list","params":{}}' \
      | timeout 60 "$out/bin/bln-mcp-server" > tools.json || true
    grep -q '"check_grammar"' tools.json
    grep -q '"improve_writing"' tools.json
    grep -q '"translate"' tools.json
    grep -q '"adjust_tone"' tools.json
    runHook postInstallCheck
  '';

  meta = with lib; {
    description = "Model Context Protocol server exposing BeLikeNative grammar, style, translation and tone tools over stdio";
    longDescription = ''
      An MCP (Model Context Protocol) stdio server that gives MCP clients such as
      Claude Desktop, Claude Code and Cursor four language tools:

        check_grammar    70 local regex rules for grammar, spelling and punctuation,
                         23 of which carry L1-specific explanations for non-native writers
        improve_writing  local wordiness, passive-voice and sentence-length analysis
                         against one of six target styles
        translate        builds a structured translation prompt for the host model
        adjust_tone      builds a structured tone-rewrite prompt for the host model

      check_grammar and improve_writing run entirely offline. No API key, no
      environment variables and no network access are required at run time.
    '';
    homepage = "https://belikenative.com/fix-grammar-with-belikenative/";
    downloadPage = "https://github.com/theluckystrike/bln-mcp-grammar-server";
    license = licenses.mit;
    mainProgram = "bln-mcp-server";
    platforms = platforms.all;
  };
}
