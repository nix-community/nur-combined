{
  lib,
  buildGoModule,

  sources,
  source ? sources.meta-rules-converter,
}:

buildGoModule (finalAttrs: {
  inherit (source)
    src
    version
    pname
    vendorHash
    ;

  ldflags = [ "-s" ];

  meta = {
    homepage = "https://github.com/MetaCubeX/meta-rules-converter";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ moraxyc ];
    mainProgram = "meta-rules-converter";
  };
})
