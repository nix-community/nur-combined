{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage rec {
  pname = "codegraph";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "colbymchenry";
    repo = "codegraph";
    rev = "v${version}";
    hash = "sha256-JLyu6FG74R/3RwBFNhen3U9swA0AFyJh7q5obNA/ZpE=";
  };
  npmDepsHash = "sha256-ilOWXV6PlKoY/JTpRYsmhtZuj/VfXWrUvAXC1MZVCn8=";
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
