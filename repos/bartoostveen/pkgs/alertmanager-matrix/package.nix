{
  lib,
  buildGoModule,
  fetchFromGitLab,
  nix-update-script,
}:

buildGoModule (finalAttrs: {
  pname = "alertmanager-matrix";
  version = "0.6.1";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitLab {
    owner = "slxh";
    repo = "matrix/alertmanager_matrix";
    tag = "v${finalAttrs.version}";
    hash = "sha256-HzOS/fuGfNtvr8p+bAM5Ux3o7VGBTRYxroYEwvRdxeY=";
  };

  patches = [
    ./0001-fix-proper-color-handing-according-to-spec.patch
  ];

  vendorHash = "sha256-bdef/RitGyOKvyoRLIgRK4Y5Q23oSEUEtXvZrkurOhA=";

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
