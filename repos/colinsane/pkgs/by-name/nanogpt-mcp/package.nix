{
  buildNpmPackage,
  fetchzip,
  lib,
  nix-update-script,
}:

buildNpmPackage (finalAttrs: {
  pname = "nanogpt-mcp";
  version = "1.4.1";

  src = fetchzip {
    url = "https://registry.npmjs.org/@nanogpt/mcp/-/mcp-${finalAttrs.version}.tgz";
    hash = "sha256-AeKYfE0GFyQVFozWvs+Ag25PX/SF5AELWILN1MqeAGA=";
  };

  npmDepsHash = "sha256-/1ZtebyPIn3fwQULUO3fAAe5SvyOHwXQB5QQIqG2ZB0=";
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
