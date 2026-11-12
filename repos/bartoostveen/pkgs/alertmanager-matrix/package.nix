{
  lib,
  buildGoModule,
  fetchFromForgejo,
  nix-update-script,
}:

buildGoModule {
  pname = "alertmanager-matrix";
  version = "0.1.0-unstable-2026-11-08";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromForgejo {
    domain = "git.bartoostveen.nl";
    owner = "bart";
    repo = "alertmanager-matrix";
    rev = "d95de56cf94f8d52b50cd6dde018e887b73e968c";
    hash = "sha256-GLhzx/7jcvNjZc5RH44NHXDBeaHvDukOFay78LMukEs=";
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
