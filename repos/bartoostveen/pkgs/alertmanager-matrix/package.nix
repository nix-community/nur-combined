{
  lib,
  buildGoModule,
  fetchFromForgejo,
  nix-update-script,
}:

buildGoModule {
  pname = "alertmanager-matrix";
  version = "0.1.0-unstable-2026-11-05";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromForgejo {
    domain = "git.bartoostveen.nl";
    owner = "bart";
    repo = "alertmanager-matrix";
    rev = "13b206b044731fec382c29a51440700ce4bb2449";
    hash = "sha256-DVG2n2QuS6nvbgglWdmJpSppGqUSVDaQMJGUIzDANA4=";
  };

  vendorHash = "sha256-ehuyzdjPFd7qi2Vwu8d5pCDV1GyPmQAP9xgIGsOtqWU=";

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
