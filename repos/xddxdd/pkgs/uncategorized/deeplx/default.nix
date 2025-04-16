{
  lib,
  sources,
  buildGoModule,
}:
buildGoModule rec {
  inherit (sources.deeplx) pname version src;
  vendorHash = "sha256-ls2oHH5wGVwGM4AxMPxl+sGgK35dfhAaIw6izE8g8Y8=";

  meta = {
    changelog = "https://github.com/OwO-Network/DeepLX/releases/tag/v${version}";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Powerful Free DeepL API, No Token Required";
    homepage = "https://deeplx.owo.network";
    license = lib.licenses.mit;
    mainProgram = "DeepLX";
  };
}
