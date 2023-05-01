{
  lib,
  sources,
  buildGoModule,
}:
buildGoModule rec {
  inherit (sources.drone-vault) pname version src;
  vendorSha256 = "sha256-T97PO3Q8C+0+QYRkl3iwRujU4mLFy16zUUjVXNlgQdw=";

  meta = with lib; {
    description = "Drone plugin for integrating with the Vault secrets manager";
    homepage = "https://docs.drone.io/configure/secrets/external/vault/";
    license = licenses.unfreeRedistributable;
  };
}
