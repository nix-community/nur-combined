{
  buildGo127Module,
  fetchFromGitHub,
  lib,
  nix-update-script,
}:
buildGo127Module (finalAttrs: {
  pname = "dlx";
  version = "1.3.1";

  src = fetchFromGitHub {
    owner = "OwO-Network";
    repo = "DLX";
    tag = "v${finalAttrs.version}";
    hash = "sha256-9LHliew71lH4UImLq/64kGa2fEbvAapdWa5ZKFa1MG4=";
  };
  __structuredAttrs = true;
  strictDeps = true;
  vendorHash = "sha256-w3KuV7+JUJYn8Bmku5aY1eyB8S+0y6ypDncVfiajDSY=";

  meta = {
    changelog = "https://github.com/OwO-Network/DLX/releases/tag/v${finalAttrs.version}";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Self-hosted translation API server";
    homepage = "https://deeplx.owo.network";
    license = lib.licenses.mit;
    mainProgram = "DLX";
  };

  passthru.updateScript = nix-update-script { };
})
