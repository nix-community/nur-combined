{
  buildNpmPackage,
  fetchzip,
  lib,
  nix-update-script,
}:

buildNpmPackage (finalAttrs: {
  pname = "nanogpt-mcp";
  version = "1.4.0";

  src = fetchzip {
    url = "https://registry.npmjs.org/@nanogpt/mcp/-/mcp-${finalAttrs.version}.tgz";
    hash = "sha256-mV6mtVIzZmRESC6q8yezsoZYl3c+TaM06Y43lbpsPSc=";
  };

  npmDepsHash = "sha256-9M8Hh68fbq0FQm/MDEPYr+K+Jc0zb8H3ra6KqklwlDQ=";
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
