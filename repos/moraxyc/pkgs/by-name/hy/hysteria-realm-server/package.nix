{
  lib,
  buildGoModule,

  sources,
  source ? sources.hysteria-realm-server,
}:

buildGoModule (finalAttrs: {
  inherit (source) pname version src;

  # nix-update auto
  vendorHash = "sha256-bSmnWWPnGSlLg8qlJEttCw76XeJgqy0AsTzjHfXmUUM=";

  ldflags = [ "-s" ];

  meta = {
    description = "Rendezvous server for Hysteria Realms";
    homepage = "https://github.com/apernet/hysteria-realm-server";
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ moraxyc ];
    mainProgram = "hysteria-realm-server";
  };
})
