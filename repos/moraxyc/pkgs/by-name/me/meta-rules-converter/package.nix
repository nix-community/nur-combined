{
  lib,
  buildGoModule,

  sources,
  source ? sources.meta-rules-converter,
}:

buildGoModule (finalAttrs: {
  inherit (source) src version pname;

  # nix-update auto
  vendorHash = "sha256-LIBrejN3Uv0/oWZeSA4XxelfhtAws8VK1yD7xVzWQvM=";

  ldflags = [ "-s" ];

  meta = {
    homepage = "https://github.com/MetaCubeX/meta-rules-converter";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ moraxyc ];
    mainProgram = "meta-rules-converter";
  };
})
