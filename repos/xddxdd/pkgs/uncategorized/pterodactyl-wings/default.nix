{
  fetchFromGitHub,
  lib,
  nix-update-script,
  buildGoModule,
}:
buildGoModule (finalAttrs: {
  pname = "pterodactyl-wings";
  version = "1.13.5-unstable-2026-11-11";
  src = fetchFromGitHub {
    owner = "pterodactyl";
    repo = "wings";
    rev = "d99a77765d0456bfe4a131742c77b1a481810326";
    hash = "sha256-Mbbmxq5eV9vNdVyJ+jW4/HzUHk/4Z00nMH0S4NRDPZA=";
  };
  __structuredAttrs = true;
  strictDeps = true;
  vendorHash = "sha256-98hvLcpcsZqC0DQ8JQ+xQ/OmvQ2fvO7neSBf3NHLlZw=";

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
