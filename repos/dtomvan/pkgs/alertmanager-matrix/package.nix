{
  pkgs,
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

  ldflags = [
    "-s"
    "-w"
  ];

  env = {
    CGO_ENABLED = "0";
  };

  # I have not installed the systemd unit and the /etc/default file here.
  # That's intentional, since they are useless on NixOS and rely on FHS

  passthru = {
    updateScript = nix-update-script { };

    services.default = {
      imports = lib.singleton (lib.modules.importApply ./service.nix { inherit pkgs; });
      alertmanager-matrix.package = finalAttrs.finalPackage;
    };
  };

  meta = {
    description = "Service for managing and receiving Alertmanager alerts on Matrix";
    homepage = "https://gitlab.com/slxh/matrix/alertmanager_matrix";
    license = lib.licenses.eupl12;
    maintainers = with lib.maintainers; [ dtomvan ];
    mainProgram = "alertmanager_matrix";
  };
})
