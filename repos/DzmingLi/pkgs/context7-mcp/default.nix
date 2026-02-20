{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
}:

buildNpmPackage rec {
  pname = "context7-mcp";
  version = "1.0.30";

  src = fetchFromGitHub {
    owner = "upstash";
    repo = "context7";
    rev = "v${version}";
    hash = "sha256-cNm/NROFHy+3cOozzvC1WUhGb7bwccvOIiMt30lAN3E=";
  };

  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';

  npmDepsHash = "sha256-E2c8ah7Hefad+JXiWXuP6hNWFGh3OzkOjoyZwqdjPpM=";

  meta = with lib; {
    description = "MCP server for Context7";
    homepage = "https://github.com/upstash/context7";
    license = licenses.mit;
    mainProgram = "context7-mcp";
  };
}
