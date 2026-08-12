{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  nix-update-script,
}:

buildNpmPackage rec {
  pname = "mcp-server-searxng";
  version = "0.3.10";

  src = fetchFromGitHub {
    owner = "kevinwatt";
    repo = "mcp-server-searxng";
    rev = "v${version}";
    hash = "sha256-tThWf2NKkQ/hI/4cnBmNF/i0HwQDvDFMpZQfVhWTblY=";
  };

  npmDepsHash = "sha256-iqBgses5blMOIKum8Sh3tp0PZhwJwwbtF4z2yBpH2oQ=";

  # The `prepare` script runs `npm run build`; build in the build phase
  # instead of during `npm pack`.
  npmPackFlags = [ "--ignore-scripts" ];

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "MCP server for SearXNG meta search integration";
    longDescription = ''
      Model Context Protocol server exposing SearXNG meta search as MCP tools.
      Supports multiple search categories, languages, time ranges and safe
      search filtering.
    '';
    homepage = "https://github.com/kevinwatt/mcp-server-searxng";
    changelog = "https://github.com/kevinwatt/mcp-server-searxng/blob/v${version}/CHANGELOG.md";
    license = licenses.mit;
    maintainers = with maintainers; [ ataraxiasjel ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
    mainProgram = "mcp-server-searxng";
  };
}
