{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage rec {
  pname = "codegraph";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "colbymchenry";
    repo = "codegraph";
    rev = "v${version}";
    hash = "sha256-k4UMQit4/Yqgyuv+x1pZqyInPpBvJ4Qy9Y8Vpgu4FNI=";
  };

  npmDepsHash = "sha256-FdWAmkYKRVnztBF4Va6chOVLdH8DHNfDM2aobCIRsq4=";
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
