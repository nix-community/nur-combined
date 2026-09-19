{
  lib,
  buildGoModule,
  fetchFromForgejo,
  nix-update-script,
}:

buildGoModule {
  pname = "alertmanager-matrix";
  version = "0.6.1-unstable-2026-09-19";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromForgejo {
    domain = "git.bartoostveen.nl";
    owner = "bart";
    repo = "alertmanager-matrix";
    rev = "0f5abd750b07e30492606a1363352d3f1cabd5a9";
    hash = "sha256-9NxmsaUvXnNDKZng5CpICCMsPAcYiZmuOxWTeSL8kKI=";
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
