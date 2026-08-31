{
  fetchFromGitHub,
  lib,
  buildGoModule,
  unstableGitUpdater,
}:
buildGoModule (finalAttrs: {
  pname = "pterodactyl-wings";
  version = "1.13.3-unstable-2026-08-14";
  src = fetchFromGitHub {
    owner = "pterodactyl";
    repo = "wings";
    rev = "d6116827313dae176ddf4741e233554392993398";
    hash = "sha256-ApIp60mHYcXQykwgScxK3rYvjzSWLPs8gFylh29JOS4=";
  };
  vendorHash = "sha256-BtATik0egFk73SNhawbGnbuzjoZioGFWeA4gZOaofTI=";

  doCheck = false;

  passthru.updateScript = unstableGitUpdater {
    url = "https://github.com/pterodactyl/wings";
    tagPrefix = "v";
  };
  meta = {
    mainProgram = "wings";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Server control plane for Pterodactyl Panel";
    homepage = "https://pterodactyl.io";
    license = lib.licenses.mit;
  };
})
