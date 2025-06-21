{
  buildGoModule,
  lib,
  sources,
}:
buildGoModule (finalAttrs: {
  inherit (sources.flapalerted) pname version src;
  vendorHash = null;

  tags = [
    "mod_httpAPI"
    "mod_log"
    "mod_roaFilter"
  ];

  ldflags = [
    "-s"
    "-w"
    "-X main.Version=${finalAttrs.version}"
  ];

  meta = {
    changelog = "https://github.com/Kioubit/FlapAlerted/releases/tag/v${finalAttrs.version}";
    mainProgram = "FlapAlerted";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "BGP Update based flap detection";
    homepage = "https://github.com/Kioubit/FlapAlerted";
    license = lib.licenses.unfree;
  };
})
