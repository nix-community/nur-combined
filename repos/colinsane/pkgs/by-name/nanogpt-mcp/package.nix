{
  buildNpmPackage,
  fetchzip,
  lib,
  nix-update-script,
}:

buildNpmPackage (finalAttrs: {
  pname = "nanogpt-mcp";
  version = "1.5.0";

  src = fetchzip {
    url = "https://registry.npmjs.org/@nanogpt/mcp/-/mcp-${finalAttrs.version}.tgz";
    hash = "sha256-/cwWHoCeYF5wXFfStwxH7Dlkg1JgsFXpw3an0z67HQY=";
  };

  npmDepsHash = "sha256-ka17FzE5QXLsNbhad7wbcVGPBk1gqqW/71TOm0x8Sxc=";
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
