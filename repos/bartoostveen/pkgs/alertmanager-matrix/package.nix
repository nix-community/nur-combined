{
  lib,
  buildGoModule,
  fetchFromForgejo,
  nix-update-script,
}:

buildGoModule {
  pname = "alertmanager-matrix";
  version = "0.1.0-unstable-2026-10-23";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromForgejo {
    domain = "git.bartoostveen.nl";
    owner = "bart";
    repo = "alertmanager-matrix";
    rev = "7f56042508bf205257ac85eeed01681695112602";
    hash = "sha256-MkhMbOBcoPFPWyb4ohVNxDmT8U5n43dDNAkzKA+dGwA=";
  };

  vendorHash = "sha256-9U7o3db73hmc34zNuY/voVxnnpK7b1LuRrb+VLMOCBk=";

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
