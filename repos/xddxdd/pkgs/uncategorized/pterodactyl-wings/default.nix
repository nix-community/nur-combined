{
  fetchFromGitHub,
  lib,
  nix-update-script,
  buildGoModule,
}:
buildGoModule (finalAttrs: {
  pname = "pterodactyl-wings";
  version = "1.13.3-unstable-2026-10-09";
  src = fetchFromGitHub {
    owner = "pterodactyl";
    repo = "wings";
    rev = "5d9e2c34b6692ae48b1afb1b7bb61694439267b2";
    hash = "sha256-qYAowX+ttW6bbyh/M9Zv6VKXLDusCyDvmiaG3zFiK0M=";
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
