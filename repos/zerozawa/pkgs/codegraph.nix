{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage rec {
  pname = "codegraph";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "colbymchenry";
    repo = "codegraph";
    rev = "v${version}";
    hash = "sha256-Ojm53hH7Zd7h05S9LIl9AGKgueUI/FSo+YJRYKp7W2I=";
  };
  npmDepsHash = "sha256-Ruk+0Ka8MfFhQKCo94klkwPoi+RJsCG0JrAyi/bEleI=";
  # copy-assets copies vendored .wasm files and schema.sql to dist/
  npmBuildScript = "build";

  meta = with lib; {
    description = "Pre-indexed code knowledge graph — semantic code intelligence via MCP";
    homepage = "https://github.com/colbymchenry/codegraph";
    license = licenses.mit;
    platforms = platforms.linux;
    mainProgram = "codegraph";
    sourceProvenance = with sourceTypes; [ fromSource ];
  };
}
