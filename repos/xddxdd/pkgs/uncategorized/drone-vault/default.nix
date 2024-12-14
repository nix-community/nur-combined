{
  lib,
  sources,
  buildGoModule,
}:
buildGoModule rec {
  inherit (sources.drone-vault) pname version src;
  vendorHash = "sha256-T97PO3Q8C+0+QYRkl3iwRujU4mLFy16zUUjVXNlgQdw=";

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Drone plugin for integrating with the Vault secrets manager";
    homepage = "https://docs.drone.io/configure/secrets/external/vault/";
    license = lib.licenses.unfreeRedistributable;
    mainProgram = "drone-vault";
  };
}
