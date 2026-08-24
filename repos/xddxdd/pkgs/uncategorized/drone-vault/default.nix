{
  fetchFromGitHub,
  lib,
  buildGoModule,
  nix-update-script,
}:
buildGoModule (finalAttrs: {
  pname = "drone-vault";
  version = "1.3.0";
  src = fetchFromGitHub {
    owner = "drone";
    repo = "drone-vault";
    tag = "v1.3.0";
    hash = "sha256-g4D+pnOo41UqPDFF3lvh/yNFVzP8rqglG+4xPx+aEzM=";
  };
  vendorHash = "sha256-T97PO3Q8C+0+QYRkl3iwRujU4mLFy16zUUjVXNlgQdw=";

  passthru.updateScript = nix-update-script { };
  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Drone plugin for integrating with the Vault secrets manager";
    homepage = "https://docs.drone.io/configure/secrets/external/vault/";
    license = lib.licenses.unfreeRedistributable;
    mainProgram = "drone-vault";
  };
})
