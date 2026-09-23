{
  buildNpmPackage,
  lib,
  fetchFromGitHub,
  nix-update-script,
}:

buildNpmPackage (final: {
  pname = "chrome-devtools-mcp";
  version = "1.10.1";

  src = fetchFromGitHub {
    owner = "ChromeDevTools";
    repo = "chrome-devtools-mcp";
    rev = "chrome-devtools-mcp-v${final.version}";
    hash = "sha256-4gF4D/r4xt0IOa6UqR2/Oad04mI2NLrH4EMmWRw/30Q=";
    fetchSubmodules = true;
  };

  npmDepsHash = "sha256-tLjVNhC8no+JeESBEsUdCxOT87sTO3lZbndbdVKC1Zs=";

  postConfigure = ''
    npm run prepare
  '';

  npmBuildScript = "bundle";
  PUPPETEER_SKIP_DOWNLOAD = true;

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex='chrome-devtools-mcp-v(.*)'"
      "--commit"
      final.pname
    ];
  };

  meta = {
    mainProgram = "chrome-devtools-mcp";
    description = "Chrome DevTools for coding agents";
    license = lib.licenses.asl20;
    platforms = lib.platforms.linux;
    homepage = "https://github.com/ChromeDevTools/chrome-devtools-mcp";
    changelog = "https://github.com/ChromeDevTools/chrome-devtools-mcp/releases/tag/v${final.version}";
  };
})
