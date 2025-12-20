{
  lib,
  buildGoModule,
  sources,
}:

buildGoModule (finalAttrs: {
  pname = "flapalerted";
  inherit (sources.flapalerted) src version;

  vendorHash = null;

  ldflags = [
    "-s"
    "-X main.Version=${finalAttrs.version}"
  ];

  meta = {
    description = "BGP Update based flap detection";
    homepage = "https://github.com/Kioubit/FlapAlerted";
    # No license
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ moraxyc ];
    mainProgram = "FlapAlerted";
  };
})
