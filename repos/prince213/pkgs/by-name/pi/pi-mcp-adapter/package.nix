{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage (finalAttrs: {
  pname = "pi-mcp-adapter";
  version = "5.2.0";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "nicobailon";
    repo = "pi-mcp-adapter";
    tag = "v${finalAttrs.version}";
    hash = "sha256-5rqEGUxi0jA7ExKh4i2KEQOHgZ3vJuZ0bf16NY23Res=";
  };

  patches = [ ./package-lock.patch ];

  npmDepsFetcherVersion = 2;
  npmDepsHash = "sha256-DDpETFq8Xmq+tQAPtsH1a/BKnBSADI2bu9EC/0ON1eY=";

  npmInstallFlags = [ "--omit=dev" ];
  npmPackFlags = [ "--ignore-scripts" ];

  dontNpmBuild = true;

  meta = {
    description = "MCP adapter for Pi coding agent";
    homepage = "https://github.com/nicobailon/pi-mcp-adapter";
    downloadPage = "https://github.com/nicobailon/pi-mcp-adapter/releases";
    changelog = "https://github.com/nicobailon/pi-mcp-adapter/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ prince213 ];
  };
})
