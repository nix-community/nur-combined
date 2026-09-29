{
  lib,
  buildGoModule,
  fetchFromForgejo,
  nix-update-script,
}:

buildGoModule {
  pname = "alertmanager-matrix";
  version = "0.1.0-unstable-2026-09-27";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromForgejo {
    domain = "git.bartoostveen.nl";
    owner = "bart";
    repo = "alertmanager-matrix";
    rev = "c3b8bb94a7dd5f5f626b7c405aaf76e936fa045d";
    hash = "sha256-BZBadIFuOMM2LmrDaMX/V/wcRKIdNGnZle7ZnsxP4j4=";
  };

  vendorHash = "sha256-SQ1ZDX9R6MEEYg+tv7JYm943kwz2jQtBDeGJY4Rqf0g=";

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
