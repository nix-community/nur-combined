{
  fetchFromGitHub,
  lib,
  nix-update-script,
  buildGoModule,
}:
buildGoModule (finalAttrs: {
  pname = "pterodactyl-wings";
  version = "1.13.3-unstable-2026-10-06";
  src = fetchFromGitHub {
    owner = "pterodactyl";
    repo = "wings";
    rev = "c2d73fb5c252e8710c0bba98f52d51dd9b7d37d2";
    hash = "sha256-qGfJfRfzZrDr2AfZbO5MOdlmro902+IRUS2GlQjoay4=";
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
