{
  lib,
  buildGoModule,

  sources,
  source ? sources.metacubex-geo,
}:

buildGoModule (finalAttrs: {
  inherit (source)
    pname
    version
    src
    vendorHash
    ;

  ldflags = [ "-s" ];

  meta = {
    description = "Easy way to manage all your Geo resources";
    homepage = "https://github.com/MetaCubeX/geo";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ moraxyc ];
    mainProgram = "geo";
  };
})
