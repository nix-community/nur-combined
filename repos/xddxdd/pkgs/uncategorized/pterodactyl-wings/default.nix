{
  fetchFromGitHub,
  lib,
  nix-update-script,
  buildGoModule,
}:
buildGoModule (finalAttrs: {
  pname = "pterodactyl-wings";
  version = "1.13.3-unstable-2026-10-07";
  src = fetchFromGitHub {
    owner = "pterodactyl";
    repo = "wings";
    rev = "17c1a5c742d5717dd0f322e4439a629469296aa4";
    hash = "sha256-uqpxrm0t0l3uiZ2qZ1KvdAfaBBBO0b8tkK0HH7Yken8=";
  };
  __structuredAttrs = true;
  strictDeps = true;
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
