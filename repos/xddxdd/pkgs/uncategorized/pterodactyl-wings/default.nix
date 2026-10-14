{
  fetchFromGitHub,
  lib,
  nix-update-script,
  buildGoModule,
}:
buildGoModule (finalAttrs: {
  pname = "pterodactyl-wings";
  version = "1.13.4-unstable-2026-10-14";
  src = fetchFromGitHub {
    owner = "pterodactyl";
    repo = "wings";
    rev = "747bc4393daf5d95fdf61d76382f5e23749cffe9";
    hash = "sha256-McD+dQChR3nAaZp1vsyykAqNvrV+CAmZgmjaOR6D5+c=";
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
