{
  lib,
  buildGoModule,
}:
buildGoModule {
  pname = "realm-identity-metrics";
  version = "0.1.0";

  src = lib.cleanSource ./.;
  vendorHash = "sha256-i0CuA5iNHtNfH2R96Z1+Wa5D4qZAfA1SeRB/YyhE5wI=";
  subPackages = [ "." ];

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
    description = "Public SPIRE certificate metadata and pinned bootstrap trust metrics";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "realm-identity-metrics";
  };
}
