{
  buildNpmPackage,
  fetchzip,
  lib,
  nix-update-script,
}:

buildNpmPackage (finalAttrs: {
  pname = "nanogpt-mcp";
  version = "1.7.0";

  src = fetchzip {
    url = "https://registry.npmjs.org/@nanogpt/mcp/-/mcp-${finalAttrs.version}.tgz";
    hash = "sha256-yv10iGJ5wXAiAVauPdEoBlmXGRY2ECAUSmJ79PH4ed8=";
  };

  npmDepsHash = "sha256-jyWIXMoBDRtC3h9+LKkhfTQJC90Koiq3QMA84rt8rdc=";
  dontNpmBuild = true;

  # generate package-lock.json with:
  # `npm install --package-lock-only @nanogpt/mcp`
  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--generate-lockfile"
    ];
  };

  meta = {
    description = "NanoGPT MCP server for Crush";
    homepage = "https://docs.nano-gpt.com/api-reference/miscellaneous/mcp-server#nanogpt-mcp-server";
    maintainers = with lib.maintainers; [ colinsane ];
  };
})
