{
  buildNpmPackage,
  fetchzip,
  lib,
  nix-update-script,
}:

buildNpmPackage (finalAttrs: {
  pname = "nanogpt-mcp";
  version = "1.5.1";

  src = fetchzip {
    url = "https://registry.npmjs.org/@nanogpt/mcp/-/mcp-${finalAttrs.version}.tgz";
    hash = "sha256-nC9UUVdg3hEl7/D1iyRY+aKZP7Nabukg6giMwKUEMss=";
  };

  npmDepsHash = "sha256-KHaBXHisPFIXcsKgiPs5hH4UbD0reKQemre5bX9S2mI=";
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
