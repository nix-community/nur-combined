{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  nix-update-script,
  nodejs_22,
}:

buildNpmPackage (finalAttrs: {
  pname = "code996";
  version = "1.4.0";

  src = fetchFromGitHub {
    owner = "hellodigua";
    repo = "code996";
    tag = "v${finalAttrs.version}";
    hash = "sha256-XUzfyKEHzQZu3jgky89bsoubJ3KQI2c75IP9jUWkEbc=";
  };

  npmDepsHash = "sha256-nKq580pNsdtav3rtDU8oV1xmJ1JiiFYlnpYActdwh1Y=";
  nodejs = nodejs_22;

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Analyze Git commit timestamps to estimate project work intensity";
    homepage = "https://github.com/hellodigua/code996";
    changelog = "https://github.com/hellodigua/code996/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    mainProgram = "code996";
    platforms = lib.platforms.all;
  };
})
