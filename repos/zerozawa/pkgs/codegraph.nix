{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage rec {
  pname = "codegraph";
  version = "1.5.0";

  src = fetchFromGitHub {
    owner = "colbymchenry";
    repo = "codegraph";
    rev = "v${version}";
    hash = "sha256-PPPOp4goz154esdUJYMu20Lby3QObsEt5z5k+9CSjwk=";
  };
  npmDepsHash = "sha256-7cGlc4q+9DoPsyPDos5BfE9n2Qmvlvl8QEDiD/y6+e0=";
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
