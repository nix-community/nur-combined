{
  buildNpmPackage,
  lib,
  fetchFromGitHub,
  nix-update-script,
}:

buildNpmPackage (final: {
  pname = "chrome-devtools-mcp";
  version = "1.6.0";

  src = fetchFromGitHub {
    owner = "ChromeDevTools";
    repo = "chrome-devtools-mcp";
    rev = "chrome-devtools-mcp-v${final.version}";
    hash = "sha256-aHbBrM/bluFjFRUfJkbxGZpdm0m3XAcAiScARKsnIm4=";
  };

  npmDepsHash = "sha256-Aqin4Y///f1j4MWcG3gA4FGvIfC4lBEGKaKfAMSFdDw=";

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
