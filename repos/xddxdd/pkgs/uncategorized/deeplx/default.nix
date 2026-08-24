{
  buildGoModule,
  fetchFromGitHub,
  lib,
  nix-update-script,
}:
buildGoModule (finalAttrs: {
  pname = "deeplx";
  version = "1.2.4";

  src = fetchFromGitHub {
    owner = "OwO-Network";
    repo = "DeepLX";
    tag = "v${finalAttrs.version}";
    hash = "sha256-7WuuO80CtmK4Zd8tI2VR0xH8votIz6AplJVoM58LU/w=";
  };
  vendorHash = "sha256-w3KuV7+JUJYn8Bmku5aY1eyB8S+0y6ypDncVfiajDSY=";

  meta = {
    changelog = "https://github.com/OwO-Network/DeepLX/releases/tag/v${finalAttrs.version}";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Powerful Free DeepL API, No Token Required";
    homepage = "https://deeplx.owo.network";
    license = lib.licenses.mit;
    mainProgram = "DeepLX";
  };

  passthru.updateScript = nix-update-script { };
})
