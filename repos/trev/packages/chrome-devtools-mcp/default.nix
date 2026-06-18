{
  buildNpmPackage,
  lib,
  fetchFromGitHub,
  nix-update-script,
}:

buildNpmPackage (final: {
  pname = "chrome-devtools-mcp";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "ChromeDevTools";
    repo = "chrome-devtools-mcp";
    rev = "chrome-devtools-mcp-v${final.version}";
    hash = "sha256-0/XwydWWtcIZ4vkndecIgbHtUGmEj6G4jO8wQrzfXGU=";
  };

  npmDepsHash = "sha256-NtWASRaPyMT19hbPXV4VriSfU/Mzj4P9W8tefJSlJt0=";

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
