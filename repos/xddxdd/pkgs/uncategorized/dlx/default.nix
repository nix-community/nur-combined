{
  buildGoModule,
  fetchFromGitHub,
  lib,
  nix-update-script,
}:
buildGoModule (finalAttrs: {
  pname = "dlx";
  version = "1.2.5";

  src = fetchFromGitHub {
    owner = "OwO-Network";
    repo = "DLX";
    tag = "v${finalAttrs.version}";
    hash = "sha256-uzjsV/FbQrbIk5TqBu3GFzzW1zjoxMwXXktt3LEexIM=";
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
