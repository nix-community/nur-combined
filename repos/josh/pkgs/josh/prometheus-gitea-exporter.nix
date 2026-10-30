{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
  testers,
}:
buildGoModule (finalAttrs: {
  pname = "prometheus-gitea-exporter";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "josh";
    repo = "gitea_exporter";
    tag = "v${finalAttrs.version}";
    hash = "sha256-PkFkstNEcuuPTZN5si2oOiF+F6oSZIaQDhbb2r8dhUY=";
  };

  vendorHash = "sha256-i5GRTFM5kvMWfPp99ji717Lt19Gtw8ttDxbJ3yn/K3I=";

  env.CGO_ENABLED = 0;
  ldflags = [
    "-s"
    "-w"
    "-X github.com/prometheus/common/version.Version=${finalAttrs.version}"
  ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=stable" ]; };

  passthru.tests = {
    version = testers.testVersion {
      package = finalAttrs.finalPackage;
      inherit (finalAttrs) version;
    };
  };

  meta = {
    description = "Prometheus exporter for Gitea pull requests and Actions workflow runs";
    homepage = "https://github.com/josh/gitea_exporter";
    license = lib.licenses.mit;
    mainProgram = "gitea_exporter";
  };
})
