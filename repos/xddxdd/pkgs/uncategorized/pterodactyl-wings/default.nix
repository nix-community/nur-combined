{
  fetchFromGitHub,
  lib,
  nix-update-script,
  buildGoModule,
}:
buildGoModule (finalAttrs: {
  pname = "pterodactyl-wings";
  version = "1.13.3-unstable-2026-09-28";
  src = fetchFromGitHub {
    owner = "pterodactyl";
    repo = "wings";
    rev = "ac9c14e2851904b963fb7b57898b65e0c44f29b6";
    hash = "sha256-8TeN3nL+ZKpHWYkj49xBm2WC391h/rdnFOVenC75piY=";
  };
  vendorHash = "sha256-BtATik0egFk73SNhawbGnbuzjoZioGFWeA4gZOaofTI=";

  doCheck = false;

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch"
    ];
  };
  meta = {
    mainProgram = "wings";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Server control plane for Pterodactyl Panel";
    homepage = "https://pterodactyl.io";
    license = lib.licenses.mit;
  };
})
