{
  lib,
  sources,
  buildGoModule,
}:
buildGoModule (finalAttrs: {
  inherit (sources.deeplx) pname version src;
  vendorHash = "sha256-HkLlgspXrUHfBGcIsFLDXB4aJzPp6D/MR1/UrY+C7i8=";

  meta = {
    changelog = "https://github.com/OwO-Network/DeepLX/releases/tag/v${finalAttrs.version}";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Powerful Free DeepL API, No Token Required";
    homepage = "https://deeplx.owo.network";
    license = lib.licenses.mit;
    mainProgram = "DeepLX";
  };
})
