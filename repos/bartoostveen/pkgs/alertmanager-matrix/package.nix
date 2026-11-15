{
  lib,
  buildGoModule,
  fetchFromGitLab,
  nix-update-script,
}:

buildGoModule (finalAttrs: {
  pname = "alertmanager-matrix";
  version = "0.6.2";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitLab {
    group = "slxh";
    owner = "matrix";
    repo = "alertmanager_matrix";
    tag = "v${finalAttrs.version}";
    hash = "sha256-rQu7GQBzgc3320pdGoyQrH4S+UKTiOxGhoya16YxdJs=";
  };

  vendorHash = "sha256-TI7zSMdnu0wWdzxtm00eM/F7HwjRh7IyBZy7VEUbbZQ=";

  ldflags = [ "-s" ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Service for managing and receiving Alertmanager alerts on Matrix";
    homepage = "https://github.com/silkeh/alertmanager_matrix";
    license = lib.licenses.eupl12;
    maintainers = with lib.maintainers; [ bartoostveen ];
    mainProgram = "alertmanager_matrix";
    platforms = lib.platforms.linux;
  };
})
