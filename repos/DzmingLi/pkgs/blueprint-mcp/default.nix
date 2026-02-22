{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
}:

let
  version = "1.9.21^{}";
in
buildNpmPackage rec {
  pname = "blueprint-mcp";
  inherit version;

  src = fetchFromGitHub {
    owner = "railsblueprint";
    repo = "blueprint-mcp";
    rev = "v${version}";
    sha256 = "sha256-TLAYKJT2QYNPDuMdgGVRnCgoT80Yz/MDNYkU4MCE/Js=";
  };

  sourceRoot = "${src.name}/server";

  npmDepsHash = "sha256-Evgt+WhAEMBXVXaaGWwVKYlTMTfesZ91IFuZTw+Tfwc=";

  dontNpmBuild = true;

  # The postinstall script is just a console.log message
  npmFlags = [ "--ignore-scripts" ];

  meta = with lib; {
    description = "MCP server for browser automation using real browser profiles";
    homepage = "https://github.com/railsblueprint/blueprint-mcp";
    license = licenses.asl20;
    mainProgram = "blueprint-mcp";
  };
}
