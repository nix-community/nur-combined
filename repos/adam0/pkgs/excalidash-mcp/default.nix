{
  # keep-sorted start
  buildNpmPackage,
  fetchFromGitHub,
  lib,
  # keep-sorted end
}:
buildNpmPackage {
  pname = "excalidash-mcp";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "chlee1001";
    repo = "excalidash-mcp";
    rev = "68d2119f12f2578f7996d68a518608d87e83a3bd";
    hash = "sha256-Fn3yDUJ3QlQql5YAIHIbr5F9/WL0fqhQh+9EyW0c35c=";
  };

  npmDepsHash = "sha256-uWSnIvTpDkgGCSDTdkcgm3O1K5Tyey5JlWtCJ5R2bM4=";
  npmBuildScript = "build";

  meta = with lib; {
    # keep-sorted start
    description = "MCP server for managing ExcaliDash drawings";
    homepage = "https://github.com/chlee1001/excalidash-mcp";
    license = licenses.mit;
    mainProgram = "excalidash-mcp";
    platforms = platforms.unix;
    # keep-sorted end
  };
}
