{
  lib,
  buildGoModule,
  callPackage,
  sources,
  source ? sources.cpa-usage-keeper,
}:

buildGoModule (finalAttrs: {
  inherit (source) pname version src;

  patches = [ ./0001-feat-embed-web-assets-in-server-binary.patch ];

  # nix-update auto
  vendorHash = "sha256-3adkU3/TjS+kzeD2fONzyfxjMzphtEtBn5QRs24TCMQ=";

  ldflags = [ "-s" ];

  preBuild = ''
    rm -rf web/dist
    cp -r ${finalAttrs.passthru.frontend} web/dist
  '';

  postInstall = ''
    mv $out/bin/{server,cpa-usage-keeper}
  '';

  passthru = {
    frontend = callPackage ./frontend.nix {
      inherit source;
      meta = lib.removeAttrs finalAttrs.meta [ "mainProgram" ];
    };
  };

  meta = {
    description = "Dashboard / Standalone Cli-Proxy-API usage tracker with SQLite persistence and built-in dashboard";
    homepage = "https://github.com/Willxup/cpa-usage-keeper";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ moraxyc ];
    mainProgram = "cpa-usage-keeper";
  };
})
