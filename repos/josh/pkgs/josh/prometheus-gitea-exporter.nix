{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
  testers,
}:
buildGoModule (finalAttrs: {
  pname = "prometheus-gitea-exporter";
  version = "0.2.4";

  src = fetchFromGitHub {
    owner = "josh";
    repo = "gitea_exporter";
    tag = "v${finalAttrs.version}";
    hash = "sha256-I648ehpJA4h0YlReRn6i/5cXp/2ANrn3KrIGnP6qzcs=";
  };

  vendorHash = "sha256-mz2C6at9EFVqewFd1rn84sjSImIhKs+Lnfol+f/+IMc=";

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
