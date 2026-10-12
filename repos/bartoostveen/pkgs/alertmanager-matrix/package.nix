{
  lib,
  buildGoModule,
  fetchFromForgejo,
  nix-update-script,
}:

buildGoModule {
  pname = "alertmanager-matrix";
  version = "0.1.0-unstable-2026-10-12";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromForgejo {
    domain = "git.bartoostveen.nl";
    owner = "bart";
    repo = "alertmanager-matrix";
    rev = "79dee073a529fd40560e3b1305133f4c7b0d454b";
    hash = "sha256-5sPjbUdvEgMuK7N7HAZyqGH0VhWPNEDuWYCn+tYdlvI=";
  };

  vendorHash = "sha256-o1sE9Z05Fe0m1WIerSKha0VhkwlUjaA2BuYu0P2RfUU=";

  ldflags = [ "-s" ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch=master" ]; };

  meta = {
    description = "Service for managing and receiving Alertmanager alerts on Matrix";
    homepage = "https://github.com/silkeh/alertmanager_matrix";
    license = lib.licenses.eupl12;
    maintainers = with lib.maintainers; [ bartoostveen ];
    mainProgram = "alertmanager_matrix";
    platforms = lib.platforms.linux;
  };
}
