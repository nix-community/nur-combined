{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage rec {
  pname = "codegraph";
  version = "1.4.1";

  src = fetchFromGitHub {
    owner = "colbymchenry";
    repo = "codegraph";
    rev = "v${version}";
    hash = "sha256-bZtzBHLbqFqY7vxWqxqKFbBtOZRnTMO/loXcVGPkwgc=";
  };
  npmDepsHash = "sha256-HVd/0c0i0g+TjPE7hCXe2GPgbTwMb3nBoepTa3Dbkvo=";
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
