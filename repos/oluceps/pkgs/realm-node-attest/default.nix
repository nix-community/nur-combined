{
  lib,
  buildGoModule,
}:
buildGoModule {
  pname = "realm-node-attest";
  version = "0.1.0";

  src = lib.cleanSource ./.;
  vendorHash = "sha256-aGUQ1cG6wG6T+H40FjqOEwol2SbokgfiB/O/Mb18TaY=";
  subPackages = [
    "cmd/realm-node-attest-agent"
    "cmd/realm-node-attest-server"
    "cmd/realm-node-attest-responder"
  ];

  env.CGO_ENABLED = "0";
  ldflags = [
    "-s"
    "-w"
  ];

  checkPhase = ''
    runHook preCheck
    go test ./...
    runHook postCheck
  '';

  meta = {
    description = "SPIRE http_fqdn node attestors and HTTP proof responder";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
}
